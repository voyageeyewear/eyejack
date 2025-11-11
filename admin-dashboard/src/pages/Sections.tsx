import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { sectionsAPI } from '../lib/api';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Label } from '../components/ui/Label';
import { Plus, Edit2, Trash2, Eye, EyeOff, GripVertical, Save, X } from 'lucide-react';

export function Sections() {
  const queryClient = useQueryClient();
  const [editingSection, setEditingSection] = useState<any>(null);
  // const [isCreating, setIsCreating] = useState(false);

  const { data: sections, isLoading } = useQuery({
    queryKey: ['sections'],
    queryFn: () => sectionsAPI.getAll(),
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) =>
      sectionsAPI.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['sections'] });
      setEditingSection(null);
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => sectionsAPI.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['sections'] });
    },
  });

  // const createMutation = useMutation({
  //   mutationFn: (data: any) => sectionsAPI.create(data),
  //   onSuccess: () => {
  //     queryClient.invalidateQueries({ queryKey: ['sections'] });
  //     setIsCreating(false);
  //   },
  // });

  const handleToggleActive = (section: any) => {
    updateMutation.mutate({
      id: section.id,
      data: {
        ...section,
        is_active: !section.is_active,
      },
    });
  };

  const handleSaveEdit = () => {
    if (editingSection) {
      updateMutation.mutate({
        id: editingSection.id,
        data: editingSection,
      });
    }
  };

  const handleDelete = (id: string) => {
    if (window.confirm('Are you sure you want to delete this section?')) {
      deleteMutation.mutate(id);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
      </div>
    );
  }

  const sectionsList = sections?.data?.data || [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Sections</h1>
          <p className="text-gray-600 mt-2">
            Manage your app's content sections and layouts
          </p>
        </div>
        <Button onClick={() => alert('Coming soon!')} variant="outline">
          <Plus className="mr-2 h-4 w-4" />
          Add Section
        </Button>
      </div>

      {/* Sections List */}
      <div className="space-y-4">
        {sectionsList.map((section: any) => (
          <Card key={section.id} className={!section.is_active ? 'opacity-60' : ''}>
            <CardHeader>
              <div className="flex items-start justify-between">
                <div className="flex items-start gap-3">
                  <GripVertical className="h-5 w-5 text-gray-600 mt-1" />
                  <div>
                    <CardTitle className="text-lg">
                      {section.section_id}
                    </CardTitle>
                    <CardDescription className="mt-1">
                      Type: {section.section_type} | Order: {section.display_order}
                    </CardDescription>
                  </div>
                </div>
                <div className="flex items-center gap-2">
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => handleToggleActive(section)}
                  >
                    {section.is_active ? (
                      <Eye className="h-4 w-4" />
                    ) : (
                      <EyeOff className="h-4 w-4" />
                    )}
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => setEditingSection(section)}
                  >
                    <Edit2 className="h-4 w-4" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => handleDelete(section.id)}
                  >
                    <Trash2 className="h-4 w-4 text-red-600" />
                  </Button>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                <div className="flex items-center gap-2">
                  <span className={`px-2 py-1 rounded text-xs font-medium ${
                    section.is_active
                      ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'
                      : 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200'
                  }`}>
                    {section.is_active ? 'Active' : 'Inactive'}
                  </span>
                  <span className="px-2 py-1 rounded text-xs font-medium bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200">
                    {section.section_type}
                  </span>
                </div>
                <details className="mt-4">
                  <summary className="cursor-pointer text-sm font-medium text-gray-600 hover:text-foreground">
                    View Settings ({Object.keys(section.settings || {}).length} properties)
                  </summary>
                  <pre className="mt-2 p-4 bg-gray-100 rounded-md text-xs overflow-auto max-h-64">
                    {JSON.stringify(section.settings, null, 2)}
                  </pre>
                </details>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Edit Modal */}
      {editingSection && (
        <div className="fixed inset-0 z-50 bg-black/50 flex items-center justify-center p-4">
          <Card className="w-full max-w-2xl max-h-[90vh] overflow-auto">
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>Edit Section</CardTitle>
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={() => setEditingSection(null)}
                >
                  <X className="h-4 w-4" />
                </Button>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="section_id">Section ID</Label>
                <Input
                  id="section_id"
                  value={editingSection.section_id}
                  onChange={(e) =>
                    setEditingSection({
                      ...editingSection,
                      section_id: e.target.value,
                    })
                  }
                />
              </div>
              <div>
                <Label htmlFor="section_type">Section Type</Label>
                <Input
                  id="section_type"
                  value={editingSection.section_type}
                  onChange={(e) =>
                    setEditingSection({
                      ...editingSection,
                      section_type: e.target.value,
                    })
                  }
                />
              </div>
              <div>
                <Label htmlFor="display_order">Display Order</Label>
                <Input
                  id="display_order"
                  type="number"
                  value={editingSection.display_order}
                  onChange={(e) =>
                    setEditingSection({
                      ...editingSection,
                      display_order: parseInt(e.target.value),
                    })
                  }
                />
              </div>
              <div>
                <Label htmlFor="settings">Settings (JSON)</Label>
                <textarea
                  id="settings"
                  className="flex min-h-[200px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-gray-600 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                  value={JSON.stringify(editingSection.settings, null, 2)}
                  onChange={(e) => {
                    try {
                      const settings = JSON.parse(e.target.value);
                      setEditingSection({
                        ...editingSection,
                        settings,
                      });
                    } catch (err) {
                      // Invalid JSON, ignore
                    }
                  }}
                />
              </div>
              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  id="is_active"
                  checked={editingSection.is_active}
                  onChange={(e) =>
                    setEditingSection({
                      ...editingSection,
                      is_active: e.target.checked,
                    })
                  }
                  className="h-4 w-4 rounded border-gray-300"
                />
                <Label htmlFor="is_active">Active</Label>
              </div>
              <div className="flex gap-2">
                <Button onClick={handleSaveEdit}>
                  <Save className="mr-2 h-4 w-4" />
                  Save Changes
                </Button>
                <Button
                  variant="outline"
                  onClick={() => setEditingSection(null)}
                >
                  Cancel
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}

