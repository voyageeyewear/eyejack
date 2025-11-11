import axios from 'axios';
import { API_BASE_URL } from './utils';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Sections API
export const sectionsAPI = {
  getAll: () => api.get('/api/admin/sections'),
  getById: (id: string) => api.get(`/api/admin/sections/${id}`),
  create: (data: any) => api.post('/api/admin/sections', data),
  update: (id: string, data: any) => api.put(`/api/admin/sections/${id}`, data),
  delete: (id: string) => api.delete(`/api/admin/sections/${id}`),
};

// Theme Settings API
export const themeAPI = {
  getAll: () => api.get('/api/admin/theme'),
  getByKey: (key: string) => api.get(`/api/admin/theme/${key}`),
  update: (key: string, data: any) => api.put(`/api/admin/theme/${key}`, data),
};

// Dashboard Stats API
export const statsAPI = {
  getStats: () => api.get('/api/admin/stats'),
};

// Preview API (Flutter endpoint)
export const previewAPI = {
  getPreview: () => api.get('/api/shopify/theme-sections'),
};

export default api;

