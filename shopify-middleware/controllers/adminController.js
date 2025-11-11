const { AppSection, AppTheme } = require('../models');

// ============================================
// SECTION MANAGEMENT
// ============================================

// Get all sections (for admin dashboard)
exports.getAllSections = async (req, res, next) => {
    try {
        const sections = await AppSection.findAll({
            order: [['display_order', 'ASC']]
        });

        console.log(`📊 Admin: Retrieved ${sections.length} sections`);

        res.json({
            success: true,
            data: sections
        });
    } catch (error) {
        console.error('❌ Error fetching sections:', error);
        next(error);
    }
};

// Get single section by ID
exports.getSectionById = async (req, res, next) => {
    try {
        const { id } = req.params;

        // Find by primary key (id) instead of section_id
        const section = await AppSection.findByPk(id);

        if (!section) {
            return res.status(404).json({
                success: false,
                error: 'Section not found'
            });
        }

        console.log(`📄 Admin: Retrieved section ID ${id} (${section.section_id})`);

        res.json({
            success: true,
            data: section
        });
    } catch (error) {
        console.error('❌ Error fetching section:', error);
        next(error);
    }
};

// Create new section
exports.createSection = async (req, res, next) => {
    try {
        const { section_id, section_type, settings, display_order, is_active } = req.body;

        // Validation
        if (!section_id || !section_type || !settings) {
            return res.status(400).json({
                success: false,
                error: 'Missing required fields: section_id, section_type, settings'
            });
        }

        // Check if section_id already exists
        const existing = await AppSection.findOne({ where: { section_id } });
        if (existing) {
            return res.status(400).json({
                success: false,
                error: `Section with ID '${section_id}' already exists`
            });
        }

        const section = await AppSection.create({
            section_id,
            section_type,
            settings,
            display_order: display_order || 999,
            is_active: is_active !== undefined ? is_active : true
        });

        console.log(`✅ Admin: Created section ${section_id}`);

        res.status(201).json({
            success: true,
            data: section
        });
    } catch (error) {
        console.error('❌ Error creating section:', error);
        next(error);
    }
};

// Update section
exports.updateSection = async (req, res, next) => {
    try {
        const { id } = req.params;
        const updates = req.body;

        // Find by primary key (id) instead of section_id
        const section = await AppSection.findByPk(id);

        if (!section) {
            return res.status(404).json({
                success: false,
                error: 'Section not found'
            });
        }

        // Update fields
        if (updates.section_id) section.section_id = updates.section_id;
        if (updates.section_type) section.section_type = updates.section_type;
        if (updates.settings) section.settings = updates.settings;
        if (updates.display_order !== undefined) section.display_order = updates.display_order;
        if (updates.is_active !== undefined) section.is_active = updates.is_active;

        await section.save();

        console.log(`✅ Admin: Updated section ID ${id} (${section.section_id})`);

        res.json({
            success: true,
            data: section
        });
    } catch (error) {
        console.error('❌ Error updating section:', error);
        next(error);
    }
};

// Delete section
exports.deleteSection = async (req, res, next) => {
    try {
        const { id } = req.params;

        // Find by primary key first to get section_id for logging
        const section = await AppSection.findByPk(id);
        
        if (!section) {
            return res.status(404).json({
                success: false,
                error: 'Section not found'
            });
        }

        const sectionId = section.section_id;
        await section.destroy();

        console.log(`🗑️  Admin: Deleted section ID ${id} (${sectionId})`);

        res.json({
            success: true,
            message: `Section '${sectionId}' deleted successfully`
        });
    } catch (error) {
        console.error('❌ Error deleting section:', error);
        next(error);
    }
};

// Toggle section active status
exports.toggleSectionStatus = async (req, res, next) => {
    try {
        const { id } = req.params;

        // Find by primary key (id) instead of section_id
        const section = await AppSection.findByPk(id);

        if (!section) {
            return res.status(404).json({
                success: false,
                error: 'Section not found'
            });
        }

        section.is_active = !section.is_active;
        await section.save();

        console.log(`🔄 Admin: Toggled section ID ${id} (${section.section_id}) to ${section.is_active ? 'active' : 'inactive'}`);

        res.json({
            success: true,
            data: section
        });
    } catch (error) {
        console.error('❌ Error toggling section status:', error);
        next(error);
    }
};

// Reorder sections
exports.reorderSections = async (req, res, next) => {
    try {
        const { sections } = req.body; // Array of { section_id, display_order }

        if (!Array.isArray(sections)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid request: sections must be an array'
            });
        }

        // Update each section's display_order
        for (const item of sections) {
            await AppSection.update(
                { display_order: item.display_order },
                { where: { section_id: item.section_id } }
            );
        }

        console.log(`🔄 Admin: Reordered ${sections.length} sections`);

        res.json({
            success: true,
            message: 'Sections reordered successfully'
        });
    } catch (error) {
        console.error('❌ Error reordering sections:', error);
        next(error);
    }
};

// ============================================
// THEME SETTINGS MANAGEMENT
// ============================================

// Get all theme settings
exports.getAllThemeSettings = async (req, res, next) => {
    try {
        const settings = await AppTheme.findAll();

        console.log(`🎨 Admin: Retrieved ${settings.length} theme settings`);

        res.json({
            success: true,
            data: settings
        });
    } catch (error) {
        console.error('❌ Error fetching theme settings:', error);
        next(error);
    }
};

// Update theme setting
exports.updateThemeSetting = async (req, res, next) => {
    try {
        const { key } = req.params;
        const { theme_value, theme_type, description } = req.body;

        if (!theme_value) {
            return res.status(400).json({
                success: false,
                error: 'theme_value is required'
            });
        }

        // Upsert (update or create)
        const [setting, created] = await AppTheme.findOrCreate({
            where: { theme_key: key },
            defaults: { theme_value, theme_type, description }
        });

        if (!created) {
            setting.theme_value = theme_value;
            if (theme_type) setting.theme_type = theme_type;
            if (description) setting.description = description;
            await setting.save();
        }

        console.log(`🎨 Admin: ${created ? 'Created' : 'Updated'} theme setting ${key}`);

        res.json({
            success: true,
            data: setting
        });
    } catch (error) {
        console.error('❌ Error updating theme setting:', error);
        next(error);
    }
};

// ============================================
// STATS & ANALYTICS
// ============================================

// Get dashboard stats
exports.getDashboardStats = async (req, res, next) => {
    try {
        const totalSections = await AppSection.count();
        const activeSections = await AppSection.count({ where: { is_active: true } });
        const inactiveSections = totalSections - activeSections;
        const themeSettings = await AppTheme.count();

        // Get sections by type
        const sectionsByType = await AppSection.findAll({
            attributes: [
                'section_type',
                [AppSection.sequelize.fn('COUNT', '*'), 'count']
            ],
            group: ['section_type']
        });

        console.log('📊 Admin: Retrieved dashboard stats');

        res.json({
            success: true,
            data: {
                totalSections,
                activeSections,
                inactiveSections,
                themeSettings,
                sectionsByType
            }
        });
    } catch (error) {
        console.error('❌ Error fetching dashboard stats:', error);
        next(error);
    }
};

