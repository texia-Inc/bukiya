import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8000/api/v1',
  headers: {
    'Content-Type': 'application/json',
  },
});

export interface EnchantmentType {
  id: number;
  name: string;
  description: string;
  effect_type: string;
  effect_value: number;
  max_level: number;
  base_success_rate: number;
  base_cost: number;
  required_materials: any;
  is_active: boolean;
  created_at: string;
  updated_at: string | null;
}

export interface EnchantmentMaterial {
  id: number;
  name: string;
  description: string;
  rarity: string;
  effect_type: string | null;
  success_rate_bonus: number;
  cost_multiplier: number;
  max_stack: number;
  is_active: boolean;
  created_at: string;
  updated_at: string | null;
}

export interface BaseResponse<T> {
  success: boolean;
  data: T;
  message: string;
  timestamp: string;
  request_id: string;
}

export const enchantmentApi = {
  // エンチャントタイプ
  getEnchantmentTypes: async (params?: {
    search?: string;
    effect_type?: string;
    page?: number;
    limit?: number;
  }): Promise<BaseResponse<EnchantmentType[]>> => {
    const response = await api.get('/enchantments/admin/types', { params });
    return response.data;
  },

  createEnchantmentType: async (data: Omit<EnchantmentType, 'id' | 'created_at' | 'updated_at'>): Promise<BaseResponse<EnchantmentType>> => {
    const response = await api.post('/enchantments/admin/types', data);
    return response.data;
  },

  updateEnchantmentType: async (id: number, data: Omit<EnchantmentType, 'id' | 'created_at' | 'updated_at'>): Promise<BaseResponse<EnchantmentType>> => {
    const response = await api.put(`/enchantments/admin/types/${id}`, data);
    return response.data;
  },

  deleteEnchantmentType: async (id: number): Promise<BaseResponse<null>> => {
    const response = await api.delete(`/enchantments/admin/types/${id}`);
    return response.data;
  },

  // エンチャント素材
  getEnchantmentMaterials: async (params?: {
    search?: string;
    rarity?: string;
    page?: number;
    limit?: number;
  }): Promise<BaseResponse<EnchantmentMaterial[]>> => {
    const response = await api.get('/enchantments/admin/materials', { params });
    return response.data;
  },

  createEnchantmentMaterial: async (data: Omit<EnchantmentMaterial, 'id' | 'created_at' | 'updated_at'>): Promise<BaseResponse<EnchantmentMaterial>> => {
    const response = await api.post('/enchantments/admin/materials', data);
    return response.data;
  },

  updateEnchantmentMaterial: async (id: number, data: Omit<EnchantmentMaterial, 'id' | 'created_at' | 'updated_at'>): Promise<BaseResponse<EnchantmentMaterial>> => {
    const response = await api.put(`/enchantments/admin/materials/${id}`, data);
    return response.data;
  },

  deleteEnchantmentMaterial: async (id: number): Promise<BaseResponse<null>> => {
    const response = await api.delete(`/enchantments/admin/materials/${id}`);
    return response.data;
  },
};

export default enchantmentApi;
