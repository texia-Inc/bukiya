import React, { useState } from 'react';
import { useCreateWeaponMutation } from '../services/api';

interface WeaponCreateModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

interface WeaponFormData {
  name: string;
  description: string;
  weapon_type_id: string;
  rarity_id: number;
  base_attack: number;
  base_price: number;
  required_level: number;
  image_url: string;
  is_craftable: boolean;
}

const weaponTypes = [
  { id: 'sword', name: '剣' },
  { id: 'staff', name: '杖' },
  { id: 'bow', name: '弓' },
  { id: 'axe', name: '斧' },
  { id: 'dagger', name: '短剣' },
];

const rarities = [
  { id: 1, name: 'Common', color: '#9e9e9e' },
  { id: 2, name: 'Rare', color: '#2196f3' },
  { id: 3, name: 'Epic', color: '#9c27b0' },
  { id: 4, name: 'Legendary', color: '#ff9800' },
];

export const WeaponCreateModal: React.FC<WeaponCreateModalProps> = ({
  isOpen,
  onClose,
  onSuccess,
}) => {
  const [createWeapon, { isLoading }] = useCreateWeaponMutation();
  const [formData, setFormData] = useState<WeaponFormData>({
    name: '',
    description: '',
    weapon_type_id: 'sword',
    rarity_id: 1,
    base_attack: 1,
    base_price: 100,
    required_level: 1,
    image_url: '',
    is_craftable: true,
  });

  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleInputChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>
  ) => {
    const { name, value, type } = e.target;
    let processedValue: any = value;
    
    if (type === 'checkbox') {
      processedValue = (e.target as HTMLInputElement).checked;
    } else if (type === 'number' || ['rarity_id', 'base_attack', 'base_price', 'required_level'].includes(name)) {
      processedValue = Number(value);
    }
    
    setFormData(prev => ({
      ...prev,
      [name]: processedValue,
    }));
    
    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  const validateForm = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!formData.name.trim()) {
      newErrors.name = '武器名は必須です';
    }
    if (formData.base_attack < 1) {
      newErrors.base_attack = '攻撃力は1以上である必要があります';
    }
    if (formData.base_price < 0) {
      newErrors.base_price = '価格は0以上である必要があります';
    }
    if (formData.required_level < 1) {
      newErrors.required_level = '必要レベルは1以上である必要があります';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    try {
      await createWeapon(formData).unwrap();
      onSuccess();
      onClose();
      // Reset form
      setFormData({
        name: '',
        description: '',
        weapon_type_id: 'sword',
        rarity_id: 1,
        base_attack: 1,
        base_price: 100,
        required_level: 1,
        image_url: '',
        is_craftable: true,
      });
    } catch (error) {
      console.error('武器作成エラー:', error);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-md max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-bold">新規武器作成</h2>
          <button
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700"
          >
            ✕
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              武器名 *
            </label>
            <input
              type="text"
              name="name"
              value={formData.name}
              onChange={handleInputChange}
              className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                errors.name ? 'border-red-500' : 'border-gray-300'
              }`}
              placeholder="武器名を入力"
            />
            {errors.name && (
              <p className="text-red-500 text-sm mt-1">{errors.name}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              説明
            </label>
            <textarea
              name="description"
              value={formData.description}
              onChange={handleInputChange}
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="武器の説明を入力"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              武器タイプ *
            </label>
            <select
              name="weapon_type_id"
              value={formData.weapon_type_id}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {weaponTypes.map(type => (
                <option key={type.id} value={type.id}>
                  {type.name}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              レアリティ *
            </label>
            <select
              name="rarity_id"
              value={formData.rarity_id}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {rarities.map(rarity => (
                <option key={rarity.id} value={rarity.id}>
                  {rarity.name}
                </option>
              ))}
            </select>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                基本攻撃力 *
              </label>
              <input
                type="number"
                name="base_attack"
                value={formData.base_attack}
                onChange={handleInputChange}
                min="1"
                className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                  errors.base_attack ? 'border-red-500' : 'border-gray-300'
                }`}
              />
              {errors.base_attack && (
                <p className="text-red-500 text-sm mt-1">{errors.base_attack}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                基本価格 *
              </label>
              <input
                type="number"
                name="base_price"
                value={formData.base_price}
                onChange={handleInputChange}
                min="0"
                className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                  errors.base_price ? 'border-red-500' : 'border-gray-300'
                }`}
              />
              {errors.base_price && (
                <p className="text-red-500 text-sm mt-1">{errors.base_price}</p>
              )}
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              必要レベル *
            </label>
            <input
              type="number"
              name="required_level"
              value={formData.required_level}
              onChange={handleInputChange}
              min="1"
              className={`w-full px-3 py-2 border rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 ${
                errors.required_level ? 'border-red-500' : 'border-gray-300'
              }`}
            />
            {errors.required_level && (
              <p className="text-red-500 text-sm mt-1">{errors.required_level}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              画像URL
            </label>
            <input
              type="url"
              name="image_url"
              value={formData.image_url}
              onChange={handleInputChange}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="https://example.com/image.jpg"
            />
          </div>

          <div className="flex items-center">
            <input
              type="checkbox"
              name="is_craftable"
              checked={formData.is_craftable}
              onChange={handleInputChange}
              className="mr-2"
            />
            <label className="text-sm font-medium text-gray-700">
              合成可能
            </label>
          </div>

          <div className="flex justify-end space-x-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-gray-600 border border-gray-300 rounded-md hover:bg-gray-50"
            >
              キャンセル
            </button>
            <button
              type="submit"
              disabled={isLoading}
              className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
            >
              {isLoading ? '作成中...' : '作成'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
