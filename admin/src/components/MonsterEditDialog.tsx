import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Button,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  FormControlLabel,
  Checkbox,
  Alert,
  CircularProgress,
  Box,
  Stack,
  Chip,
  Typography,
} from '@mui/material';
import { useUpdateMonsterMutation } from '../services/api';
import type { MonsterMaster, MonsterMasterUpdate } from '../types';

interface MonsterEditDialogProps {
  open: boolean;
  monster: MonsterMaster | null;
  onClose: () => void;
  onSuccess: () => void;
}

interface MonsterFormData extends MonsterMasterUpdate {
  is_active: boolean;
}

const monsterTypes = [
  { id: 'beast', name: '野獣' },
  { id: 'undead', name: 'アンデッド' },
  { id: 'dragon', name: 'ドラゴン' },
  { id: 'elemental', name: 'エレメンタル' },
  { id: 'demon', name: '悪魔' },
  { id: 'humanoid', name: '人型' },
];

const elements = [
  { id: 'none', name: 'なし' },
  { id: 'fire', name: '火' },
  { id: 'ice', name: '氷' },
  { id: 'thunder', name: '雷' },
  { id: 'earth', name: '土' },
  { id: 'wind', name: '風' },
  { id: 'light', name: '光' },
  { id: 'dark', name: '闇' },
];

const areaOptions = [
  { id: 'forest', name: '森林' },
  { id: 'cave', name: '洞窟' },
  { id: 'mountain', name: '山岳' },
  { id: 'ruins', name: '遺跡' },
  { id: 'desert', name: '砂漠' },
];

export const MonsterEditDialog: React.FC<MonsterEditDialogProps> = ({
  open,
  monster,
  onClose,
  onSuccess,
}) => {
  const [updateMonster, { isLoading }] = useUpdateMonsterMutation();
  const [formData, setFormData] = useState<MonsterFormData>({
    name: '',
    monster_type: 'beast',
    level: 1,
    hp: 100,
    attack: 10,
    defense: 5,
    element: null,
    weakness: null,
    resistance: null,
    spawn_areas: 'forest',
    spawn_weight: 10,
    min_required_weapon_level: 1,
    base_gold_reward: 50,
    experience_reward: 25,
    is_active: true,
  });

  const [selectedAreas, setSelectedAreas] = useState<string[]>(['forest']);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [submitError, setSubmitError] = useState<string>('');

  // Initialize form data when monster changes
  useEffect(() => {
    if (monster) {
      setFormData({
        name: monster.name,
        monster_type: monster.monster_type,
        level: monster.level,
        hp: monster.hp,
        attack: monster.attack,
        defense: monster.defense,
        element: monster.element,
        weakness: monster.weakness,
        resistance: monster.resistance,
        spawn_areas: monster.spawn_areas,
        spawn_weight: monster.spawn_weight,
        min_required_weapon_level: monster.min_required_weapon_level,
        base_gold_reward: monster.base_gold_reward,
        experience_reward: monster.experience_reward,
        is_active: monster.is_active,
      });
      setSelectedAreas(monster.spawn_areas ? monster.spawn_areas.split(',').filter(Boolean) : []);
    }
  }, [monster]);

  const handleInputChange = (field: keyof MonsterFormData, value: any) => {
    setFormData(prev => ({
      ...prev,
      [field]: value,
    }));
    
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

  const handleAreaToggle = (areaId: string) => {
    setSelectedAreas(prev => {
      const newAreas = prev.includes(areaId)
        ? prev.filter(id => id !== areaId)
        : [...prev, areaId];
      
      // Update spawn_areas in form data
      setFormData(prevData => ({
        ...prevData,
        spawn_areas: newAreas.join(','),
      }));
      
      return newAreas;
    });
  };

  const validateForm = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!formData.name?.trim()) {
      newErrors.name = 'モンスター名は必須です';
    }
    if (formData.level && formData.level < 1) {
      newErrors.level = 'レベルは1以上である必要があります';
    }
    if (formData.hp && formData.hp < 1) {
      newErrors.hp = 'HPは1以上である必要があります';
    }
    if (formData.attack !== undefined && formData.attack < 0) {
      newErrors.attack = '攻撃力は0以上である必要があります';
    }
    if (formData.defense !== undefined && formData.defense < 0) {
      newErrors.defense = '防御力は0以上である必要があります';
    }
    if (formData.spawn_weight !== undefined && (formData.spawn_weight < 0 || formData.spawn_weight > 100)) {
      newErrors.spawn_weight = '出現率は0から100の間である必要があります';
    }
    if (formData.min_required_weapon_level && formData.min_required_weapon_level < 1) {
      newErrors.min_required_weapon_level = '必要武器レベルは1以上である必要があります';
    }
    if (formData.base_gold_reward !== undefined && formData.base_gold_reward < 0) {
      newErrors.base_gold_reward = 'ゴールド報酬は0以上である必要があります';
    }
    if (formData.experience_reward !== undefined && formData.experience_reward < 0) {
      newErrors.experience_reward = '経験値報酬は0以上である必要があります';
    }
    if (selectedAreas.length === 0) {
      newErrors.spawn_areas = '少なくとも1つの出現エリアを選択してください';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async () => {
    setSubmitError('');
    
    if (!monster || !validateForm()) {
      return;
    }

    try {
      // Remove is_active from the data sent to API if needed
      const { is_active, ...updateData } = formData;
      const finalData = { ...updateData, is_active };
      
      await updateMonster({ 
        id: monster.id, 
        monster: finalData 
      }).unwrap();
      onSuccess();
      handleClose();
    } catch (error: any) {
      console.error('モンスター更新エラー:', error);
      setSubmitError(error?.data?.message || 'モンスターの更新に失敗しました');
    }
  };

  const handleClose = () => {
    setErrors({});
    setSubmitError('');
    onClose();
  };

  if (!monster) {
    return null;
  }

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="md"
      fullWidth
    >
      <DialogTitle>モンスター編集: {monster.name}</DialogTitle>
      <DialogContent>
        {submitError && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {submitError}
          </Alert>
        )}
        
        <Stack spacing={3} sx={{ mt: 1 }}>
          {/* 基本情報 */}
          <Box>
            <Typography variant="h6" gutterBottom>基本情報</Typography>
            <Stack spacing={2}>
              <TextField
                fullWidth
                label="モンスター名"
                value={formData.name}
                onChange={(e) => handleInputChange('name', e.target.value)}
                error={!!errors.name}
                helperText={errors.name}
                required
              />

              <Box sx={{ display: 'flex', gap: 2 }}>
                <FormControl fullWidth>
                  <InputLabel>モンスタータイプ</InputLabel>
                  <Select
                    value={formData.monster_type}
                    label="モンスタータイプ"
                    onChange={(e) => handleInputChange('monster_type', e.target.value)}
                  >
                    {monsterTypes.map(type => (
                      <MenuItem key={type.id} value={type.id}>
                        {type.name}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>

                <TextField
                  fullWidth
                  label="レベル"
                  type="number"
                  value={formData.level || ''}
                  onChange={(e) => handleInputChange('level', Number(e.target.value))}
                  error={!!errors.level}
                  helperText={errors.level}
                  inputProps={{ min: 1 }}
                  required
                />
              </Box>
            </Stack>
          </Box>

          {/* ステータス */}
          <Box>
            <Typography variant="h6" gutterBottom>ステータス</Typography>
            <Stack spacing={2}>
              <Box sx={{ display: 'flex', gap: 2 }}>
                <TextField
                  fullWidth
                  label="HP"
                  type="number"
                  value={formData.hp || ''}
                  onChange={(e) => handleInputChange('hp', Number(e.target.value))}
                  error={!!errors.hp}
                  helperText={errors.hp}
                  inputProps={{ min: 1 }}
                  required
                />

                <TextField
                  fullWidth
                  label="攻撃力"
                  type="number"
                  value={formData.attack || ''}
                  onChange={(e) => handleInputChange('attack', Number(e.target.value))}
                  error={!!errors.attack}
                  helperText={errors.attack}
                  inputProps={{ min: 0 }}
                  required
                />

                <TextField
                  fullWidth
                  label="防御力"
                  type="number"
                  value={formData.defense || ''}
                  onChange={(e) => handleInputChange('defense', Number(e.target.value))}
                  error={!!errors.defense}
                  helperText={errors.defense}
                  inputProps={{ min: 0 }}
                  required
                />
              </Box>
            </Stack>
          </Box>

          {/* 属性 */}
          <Box>
            <Typography variant="h6" gutterBottom>属性</Typography>
            <Box sx={{ display: 'flex', gap: 2 }}>
              <FormControl fullWidth>
                <InputLabel>属性</InputLabel>
                <Select
                  value={formData.element || 'none'}
                  label="属性"
                  onChange={(e) => handleInputChange('element', e.target.value === 'none' ? null : e.target.value)}
                >
                  {elements.map(element => (
                    <MenuItem key={element.id} value={element.id}>
                      {element.name}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>

              <FormControl fullWidth>
                <InputLabel>弱点</InputLabel>
                <Select
                  value={formData.weakness || 'none'}
                  label="弱点"
                  onChange={(e) => handleInputChange('weakness', e.target.value === 'none' ? null : e.target.value)}
                >
                  {elements.map(element => (
                    <MenuItem key={element.id} value={element.id}>
                      {element.name}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>

              <FormControl fullWidth>
                <InputLabel>耐性</InputLabel>
                <Select
                  value={formData.resistance || 'none'}
                  label="耐性"
                  onChange={(e) => handleInputChange('resistance', e.target.value === 'none' ? null : e.target.value)}
                >
                  {elements.map(element => (
                    <MenuItem key={element.id} value={element.id}>
                      {element.name}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Box>
          </Box>

          {/* 出現設定 */}
          <Box>
            <Typography variant="h6" gutterBottom>出現設定</Typography>
            <Stack spacing={2}>
              <Box>
                <Typography variant="body2" gutterBottom>
                  出現エリア {errors.spawn_areas && <span style={{ color: 'red' }}>*{errors.spawn_areas}</span>}
                </Typography>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                  {areaOptions.map(area => (
                    <Chip
                      key={area.id}
                      label={area.name}
                      clickable
                      color={selectedAreas.includes(area.id) ? 'primary' : 'default'}
                      onClick={() => handleAreaToggle(area.id)}
                    />
                  ))}
                </Box>
              </Box>

              <Box sx={{ display: 'flex', gap: 2 }}>
                <TextField
                  fullWidth
                  label="出現率 (0-100)"
                  type="number"
                  value={formData.spawn_weight || ''}
                  onChange={(e) => handleInputChange('spawn_weight', Number(e.target.value))}
                  error={!!errors.spawn_weight}
                  helperText={errors.spawn_weight}
                  inputProps={{ min: 0, max: 100 }}
                  required
                />

                <TextField
                  fullWidth
                  label="必要武器レベル"
                  type="number"
                  value={formData.min_required_weapon_level || ''}
                  onChange={(e) => handleInputChange('min_required_weapon_level', Number(e.target.value))}
                  error={!!errors.min_required_weapon_level}
                  helperText={errors.min_required_weapon_level}
                  inputProps={{ min: 1 }}
                  required
                />
              </Box>
            </Stack>
          </Box>

          {/* 報酬 */}
          <Box>
            <Typography variant="h6" gutterBottom>報酬</Typography>
            <Box sx={{ display: 'flex', gap: 2 }}>
              <TextField
                fullWidth
                label="ゴールド報酬"
                type="number"
                value={formData.base_gold_reward || ''}
                onChange={(e) => handleInputChange('base_gold_reward', Number(e.target.value))}
                error={!!errors.base_gold_reward}
                helperText={errors.base_gold_reward}
                inputProps={{ min: 0 }}
                required
              />

              <TextField
                fullWidth
                label="経験値報酬"
                type="number"
                value={formData.experience_reward || ''}
                onChange={(e) => handleInputChange('experience_reward', Number(e.target.value))}
                error={!!errors.experience_reward}
                helperText={errors.experience_reward}
                inputProps={{ min: 0 }}
                required
              />
            </Box>
          </Box>

          <FormControlLabel
            control={
              <Checkbox
                checked={formData.is_active}
                onChange={(e) => handleInputChange('is_active', e.target.checked)}
              />
            }
            label="有効"
          />
        </Stack>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose} disabled={isLoading}>
          キャンセル
        </Button>
        <Button 
          onClick={handleSubmit} 
          variant="contained" 
          disabled={isLoading}
          startIcon={isLoading ? <CircularProgress size={20} /> : null}
        >
          {isLoading ? '更新中...' : '更新'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};