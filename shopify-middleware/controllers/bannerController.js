const { CollectionBanner } = require('../models');

// Get all banners for a specific collection
exports.getBannersByCollection = async (req, res) => {
    try {
        const { collectionHandle } = req.params;
        
        const banners = await CollectionBanner.findAll({
            where: {
                collection_handle: collectionHandle,
                is_active: true
            },
            order: [
                ['banner_position', 'ASC'],
                ['display_order', 'ASC']
            ]
        });
        
        res.json({
            success: true,
            data: banners
        });
    } catch (error) {
        console.error('Error fetching banners:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch banners',
            error: error.message
        });
    }
};

// Get all banners (for admin dashboard)
exports.getAllBanners = async (req, res) => {
    try {
        const banners = await CollectionBanner.findAll({
            order: [
                ['collection_handle', 'ASC'],
                ['banner_position', 'ASC'],
                ['display_order', 'ASC']
            ]
        });
        
        res.json({
            success: true,
            data: banners
        });
    } catch (error) {
        console.error('Error fetching all banners:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch banners',
            error: error.message
        });
    }
};

// Get single banner by ID
exports.getBannerById = async (req, res) => {
    try {
        const { id } = req.params;
        
        const banner = await CollectionBanner.findByPk(id);
        
        if (!banner) {
            return res.status(404).json({
                success: false,
                message: 'Banner not found'
            });
        }
        
        res.json({
            success: true,
            data: banner
        });
    } catch (error) {
        console.error('Error fetching banner:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch banner',
            error: error.message
        });
    }
};

// Create new banner
exports.createBanner = async (req, res) => {
    try {
        const bannerData = req.body;
        
        const banner = await CollectionBanner.create(bannerData);
        
        res.status(201).json({
            success: true,
            message: 'Banner created successfully',
            data: banner
        });
    } catch (error) {
        console.error('Error creating banner:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to create banner',
            error: error.message
        });
    }
};

// Update banner
exports.updateBanner = async (req, res) => {
    try {
        const { id } = req.params;
        const updates = req.body;
        
        const banner = await CollectionBanner.findByPk(id);
        
        if (!banner) {
            return res.status(404).json({
                success: false,
                message: 'Banner not found'
            });
        }
        
        await banner.update(updates);
        
        res.json({
            success: true,
            message: 'Banner updated successfully',
            data: banner
        });
    } catch (error) {
        console.error('Error updating banner:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update banner',
            error: error.message
        });
    }
};

// Delete banner
exports.deleteBanner = async (req, res) => {
    try {
        const { id } = req.params;
        
        const banner = await CollectionBanner.findByPk(id);
        
        if (!banner) {
            return res.status(404).json({
                success: false,
                message: 'Banner not found'
            });
        }
        
        await banner.destroy();
        
        res.json({
            success: true,
            message: 'Banner deleted successfully'
        });
    } catch (error) {
        console.error('Error deleting banner:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to delete banner',
            error: error.message
        });
    }
};

// Toggle banner active status
exports.toggleBannerStatus = async (req, res) => {
    try {
        const { id } = req.params;
        
        const banner = await CollectionBanner.findByPk(id);
        
        if (!banner) {
            return res.status(404).json({
                success: false,
                message: 'Banner not found'
            });
        }
        
        await banner.update({ is_active: !banner.is_active });
        
        res.json({
            success: true,
            message: `Banner ${banner.is_active ? 'activated' : 'deactivated'} successfully`,
            data: banner
        });
    } catch (error) {
        console.error('Error toggling banner status:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to toggle banner status',
            error: error.message
        });
    }
};

