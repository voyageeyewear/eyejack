import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Plus, Edit2, Trash2, Eye, EyeOff } from 'lucide-react';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import axios from 'axios';
import { API_BASE_URL } from '../lib/utils';

interface Banner {
  id: number;
  collection_handle: string;
  banner_position: string;
  banner_type: string;
  banner_url: string;
  click_url?: string;
  title?: string;
  subtitle?: string;
  is_active: boolean;
  display_order: number;
}

export default function Banners() {
  const queryClient = useQueryClient();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingBanner, setEditingBanner] = useState<Banner | null>(null);
  const [formData, setFormData] = useState({
    collection_handle: '',
    banner_position: 'top',
    banner_type: 'image',
    banner_url: '',
    click_url: '',
    title: '',
    subtitle: '',
    is_active: true,
    display_order: 1
  });

  // Fetch all banners
  const { data: banners, isLoading } = useQuery({
    queryKey: ['banners'],
    queryFn: async () => {
      const response = await axios.get(`${API_BASE_URL}/api/banners`);
      return response.data.data as Banner[];
    }
  });

  // Create banner mutation
  const createMutation = useMutation({
    mutationFn: async (data: any) => {
      const response = await axios.post(`${API_BASE_URL}/api/banners`, data);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['banners'] });
      setIsModalOpen(false);
      resetForm();
    }
  });

  // Update banner mutation
  const updateMutation = useMutation({
    mutationFn: async ({ id, data }: { id: number; data: any }) => {
      const response = await axios.put(`${API_BASE_URL}/api/banners/${id}`, data);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['banners'] });
      setIsModalOpen(false);
      setEditingBanner(null);
      resetForm();
    }
  });

  // Delete banner mutation
  const deleteMutation = useMutation({
    mutationFn: async (id: number) => {
      await axios.delete(`${API_BASE_URL}/api/banners/${id}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['banners'] });
    }
  });

  // Toggle active status mutation
  const toggleMutation = useMutation({
    mutationFn: async (id: number) => {
      await axios.patch(`${API_BASE_URL}/api/banners/${id}/toggle`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['banners'] });
    }
  });

  const resetForm = () => {
    setFormData({
      collection_handle: '',
      banner_position: 'top',
      banner_type: 'image',
      banner_url: '',
      click_url: '',
      title: '',
      subtitle: '',
      is_active: true,
      display_order: 1
    });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (editingBanner) {
      updateMutation.mutate({ id: editingBanner.id, data: formData });
    } else {
      createMutation.mutate(formData);
    }
  };

  const handleEdit = (banner: Banner) => {
    setEditingBanner(banner);
    setFormData({
      collection_handle: banner.collection_handle,
      banner_position: banner.banner_position,
      banner_type: banner.banner_type,
      banner_url: banner.banner_url,
      click_url: banner.click_url || '',
      title: banner.title || '',
      subtitle: banner.subtitle || '',
      is_active: banner.is_active,
      display_order: banner.display_order
    });
    setIsModalOpen(true);
  };

  const handleDelete = (id: number) => {
    if (confirm('Are you sure you want to delete this banner?')) {
      deleteMutation.mutate(id);
    }
  };

  const getBannersByCollection = () => {
    const grouped: { [key: string]: Banner[] } = {};
    banners?.forEach(banner => {
      if (!grouped[banner.collection_handle]) {
        grouped[banner.collection_handle] = [];
      }
      grouped[banner.collection_handle].push(banner);
    });
    return grouped;
  };

  if (isLoading) {
    return (
      <div className="p-8">
        <div className="text-center">Loading banners...</div>
      </div>
    );
  }

  const bannersByCollection = getBannersByCollection();

  return (
    <div className="p-8">
      {/* Header */}
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Collection Banners</h1>
          <p className="text-sm text-gray-600 mt-1">
            Manage banners that appear in collection pages
          </p>
        </div>
        <Button
          onClick={() => {
            setEditingBanner(null);
            resetForm();
            setIsModalOpen(true);
          }}
        >
          <Plus className="w-4 h-4 mr-2" />
          Add Banner
        </Button>
      </div>

      {/* Banners by Collection */}
      {Object.keys(bannersByCollection).length === 0 ? (
        <Card className="p-12 text-center">
          <p className="text-gray-600">No banners found. Click "Add Banner" to create one.</p>
        </Card>
      ) : (
        <div className="space-y-6">
          {Object.entries(bannersByCollection).map(([collection, collectionBanners]) => (
            <Card key={collection} className="p-6">
              <h2 className="text-lg font-semibold mb-4 capitalize">{collection}</h2>
              <div className="grid gap-4">
                {collectionBanners.map(banner => (
                  <div
                    key={banner.id}
                    className="flex items-center gap-4 p-4 bg-gray-50 rounded-lg"
                  >
                    {/* Banner Preview */}
                    <img
                      src={banner.banner_url}
                      alt={banner.title || 'Banner'}
                      className="w-32 h-20 object-cover rounded"
                    />
                    
                    {/* Banner Info */}
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="text-sm font-medium">{banner.title || 'Untitled'}</span>
                        <span className="text-xs px-2 py-1 bg-blue-100 text-blue-700 rounded">
                          {banner.banner_position}
                        </span>
                        {!banner.is_active && (
                          <span className="text-xs px-2 py-1 bg-red-100 text-red-700 rounded">
                            Inactive
                          </span>
                        )}
                      </div>
                      <p className="text-sm text-gray-600">{banner.subtitle}</p>
                      <p className="text-xs text-gray-500 mt-1">
                        Type: {banner.banner_type} • Order: {banner.display_order}
                      </p>
                    </div>

                    {/* Actions */}
                    <div className="flex gap-2">
                      <button
                        onClick={() => toggleMutation.mutate(banner.id)}
                        className="p-2 hover:bg-gray-200 rounded"
                        title={banner.is_active ? 'Deactivate' : 'Activate'}
                      >
                        {banner.is_active ? (
                          <Eye className="w-4 h-4 text-green-600" />
                        ) : (
                          <EyeOff className="w-4 h-4 text-gray-400" />
                        )}
                      </button>
                      <button
                        onClick={() => handleEdit(banner)}
                        className="p-2 hover:bg-gray-200 rounded"
                        title="Edit"
                      >
                        <Edit2 className="w-4 h-4 text-blue-600" />
                      </button>
                      <button
                        onClick={() => handleDelete(banner.id)}
                        className="p-2 hover:bg-gray-200 rounded"
                        title="Delete"
                      >
                        <Trash2 className="w-4 h-4 text-red-600" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Add/Edit Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <h2 className="text-xl font-bold mb-4">
              {editingBanner ? 'Edit Banner' : 'Add New Banner'}
            </h2>
            
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Collection Handle *</label>
                <input
                  type="text"
                  required
                  value={formData.collection_handle}
                  onChange={e => setFormData({ ...formData, collection_handle: e.target.value })}
                  placeholder="e.g., sunglasses, eyeglasses"
                  className="w-full px-3 py-2 border rounded"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Banner Position *</label>
                  <select
                    value={formData.banner_position}
                    onChange={e => setFormData({ ...formData, banner_position: e.target.value })}
                    className="w-full px-3 py-2 border rounded"
                  >
                    <option value="top">Top</option>
                    <option value="after_6">After 6 Products</option>
                    <option value="after_12">After 12 Products</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1">Banner Type *</label>
                  <select
                    value={formData.banner_type}
                    onChange={e => setFormData({ ...formData, banner_type: e.target.value })}
                    className="w-full px-3 py-2 border rounded"
                  >
                    <option value="image">Image</option>
                    <option value="video">Video</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Banner URL *</label>
                <input
                  type="url"
                  required
                  value={formData.banner_url}
                  onChange={e => setFormData({ ...formData, banner_url: e.target.value })}
                  placeholder="https://cdn.shopify.com/..."
                  className="w-full px-3 py-2 border rounded"
                />
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Click URL</label>
                <input
                  type="text"
                  value={formData.click_url}
                  onChange={e => setFormData({ ...formData, click_url: e.target.value })}
                  placeholder="/collection/sale"
                  className="w-full px-3 py-2 border rounded"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Title</label>
                  <input
                    type="text"
                    value={formData.title}
                    onChange={e => setFormData({ ...formData, title: e.target.value })}
                    placeholder="Summer Sale"
                    className="w-full px-3 py-2 border rounded"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1">Subtitle</label>
                  <input
                    type="text"
                    value={formData.subtitle}
                    onChange={e => setFormData({ ...formData, subtitle: e.target.value })}
                    placeholder="Up to 50% OFF"
                    className="w-full px-3 py-2 border rounded"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Display Order</label>
                  <input
                    type="number"
                    min="1"
                    value={formData.display_order}
                    onChange={e => setFormData({ ...formData, display_order: parseInt(e.target.value) })}
                    className="w-full px-3 py-2 border rounded"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1">Status</label>
                  <select
                    value={formData.is_active ? 'active' : 'inactive'}
                    onChange={e => setFormData({ ...formData, is_active: e.target.value === 'active' })}
                    className="w-full px-3 py-2 border rounded"
                  >
                    <option value="active">Active</option>
                    <option value="inactive">Inactive</option>
                  </select>
                </div>
              </div>

              <div className="flex gap-3 pt-4">
                <Button type="submit" disabled={createMutation.isPending || updateMutation.isPending}>
                  {editingBanner ? 'Update Banner' : 'Create Banner'}
                </Button>
                <Button
                  type="button"
                  variant="secondary"
                  onClick={() => {
                    setIsModalOpen(false);
                    setEditingBanner(null);
                    resetForm();
                  }}
                >
                  Cancel
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

