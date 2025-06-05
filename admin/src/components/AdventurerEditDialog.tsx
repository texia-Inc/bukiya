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
  Typography,
} from '@mui/material';
import { useUpdateAdventurerMutation } from '../services/api';
import type { AdventurerMaster, AdventurerMasterUpdate } from '../types';

interface AdventurerEditDialogProps {
  open: boolean;
  adventurer: AdventurerMaster | null;
  onClose: () => void;
  onSuccess: () => void;
}

interface AdventurerFormData extends AdventurerMasterUpdate {
  is_active: boolean;
}

const professions = [
  { id: 'warrior', name: '戦士' },
  { id: 'archer', name: '弓使い' },
  { id: 'mage', name: '魔法使い' },
  { id: 'rogue', name: '盗賊' },
  { id: 'paladin', name: '聖騎士' },
];

const personalities = [
  { id: 'generous', name: '気前が良い' },
  { id: 'normal', name: '普通' },
  { id: 'stingy', name: 'けち' },
  { id: 'wealthy', name: '裕福' },
  { id: 'poor', name: '貧乏' },
];

const weaponTypes = [
  { id: 'sword', name: '剣' },
  { id: 'bow', name: '弓' },
  { id: 'staff', name: '杖' },
  { id: 'dagger', name: '短剣' },
  { id: 'hammer', name: 'ハンマー' },
];

export const AdventurerEditDialog: React.FC<AdventurerEditDialogProps> = ({
  open,
  adventurer,
  onClose,
  onSuccess,
}) => {
  const [updateAdventurer, { isLoading }] = useUpdateAdventurerMutation();
  const [formData, setFormData] = useState<AdventurerFormData>({
    name: '',
    profession: 'warrior',
    level: 1,
    personality: 'normal',
    trust_level: 1,
    budget_min: 100,
    budget_max: 1000,
    preferred_weapon_type: 'sword',
    min_attack_requirement: 10,
    urgency_tendency: 3,
    spawn_weight: 10,
    is_active: true,
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [submitError, setSubmitError] = useState<string>('');

  // Initialize form data when adventurer changes
  useEffect(() => {
    if (adventurer) {
      setFormData({
        name: adventurer.name,
        profession: adventurer.profession,
        level: adventurer.level,
        personality: adventurer.personality,
        trust_level: adventurer.trust_level,
        budget_min: adventurer.budget_min,
        budget_max: adventurer.budget_max,
        preferred_weapon_type: adventurer.preferred_weapon_type,
        min_attack_requirement: adventurer.min_attack_requirement,
        urgency_tendency: adventurer.urgency_tendency,
        spawn_weight: adventurer.spawn_weight,
        is_active: adventurer.is_active,
      });
    }
  }, [adventurer]);

  const handleInputChange = (field: keyof AdventurerFormData, value: any) => {
    setFormData(prev => ({
      ...prev,
      [field]: value,
    }));
    
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

  const validateForm = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!formData.name?.trim()) {
      newErrors.name = '冒険者名は必須です';
    }
    if (formData.level && formData.level < 1) {
      newErrors.level = 'レベルは1以上である必要があります';
    }
    if (formData.trust_level && (formData.trust_level < 1 || formData.trust_level > 10)) {
      newErrors.trust_level = '信頼度は1から10の間である必要があります';
    }
    if (formData.budget_min !== undefined && formData.budget_min < 0) {
      newErrors.budget_min = '最小予算は0以上である必要があります';
    }
    if (formData.budget_max !== undefined && formData.budget_min !== undefined && formData.budget_max < formData.budget_min) {
      newErrors.budget_max = '最大予算は最小予算以上である必要があります';
    }
    if (formData.min_attack_requirement !== undefined && formData.min_attack_requirement < 0) {
      newErrors.min_attack_requirement = '最小攻撃力要求は0以上である必要があります';
    }
    if (formData.urgency_tendency && (formData.urgency_tendency < 1 || formData.urgency_tendency > 5)) {
      newErrors.urgency_tendency = '緊急度は1から5の間である必要があります';
    }
    if (formData.spawn_weight !== undefined && (formData.spawn_weight < 0 || formData.spawn_weight > 100)) {
      newErrors.spawn_weight = '出現率は0から100の間である必要があります';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async () => {
    setSubmitError('');
    
    if (!adventurer || !validateForm()) {
      return;
    }

    try {
      // Remove is_active from the data sent to API if needed
      const { is_active, ...updateData } = formData;
      const finalData = { ...updateData, is_active };
      
      await updateAdventurer({ 
        id: adventurer.id, 
        adventurer: finalData 
      }).unwrap();
      onSuccess();
      handleClose();
    } catch (error: any) {
      console.error('冒険者更新エラー:', error);
      setSubmitError(error?.data?.message || '冒険者の更新に失敗しました');
    }
  };

  const handleClose = () => {
    setErrors({});
    setSubmitError('');
    onClose();
  };

  if (!adventurer) {
    return null;
  }

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="md"
      fullWidth
    >
      <DialogTitle>冒険者編集: {adventurer.name}</DialogTitle>
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
                label="冒険者名"
                value={formData.name}
                onChange={(e) => handleInputChange('name', e.target.value)}
                error={!!errors.name}
                helperText={errors.name}
                required
              />

              <Box sx={{ display: 'flex', gap: 2 }}>
                <FormControl fullWidth>
                  <InputLabel>職業</InputLabel>
                  <Select
                    value={formData.profession}
                    label="職業"
                    onChange={(e) => handleInputChange('profession', e.target.value)}
                  >
                    {professions.map(profession => (
                      <MenuItem key={profession.id} value={profession.id}>
                        {profession.name}
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

          {/* 性格・信頼度 */}
          <Box>
            <Typography variant="h6" gutterBottom>性格・信頼度</Typography>
            <Box sx={{ display: 'flex', gap: 2 }}>
              <FormControl fullWidth>
                <InputLabel>性格</InputLabel>
                <Select
                  value={formData.personality}
                  label="性格"
                  onChange={(e) => handleInputChange('personality', e.target.value)}
                >
                  {personalities.map(personality => (
                    <MenuItem key={personality.id} value={personality.id}>
                      {personality.name}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>

              <TextField
                fullWidth
                label="信頼度 (1-10)"
                type="number"
                value={formData.trust_level || ''}
                onChange={(e) => handleInputChange('trust_level', Number(e.target.value))}
                error={!!errors.trust_level}
                helperText={errors.trust_level}
                inputProps={{ min: 1, max: 10 }}
                required
              />
            </Box>
          </Box>

          {/* 予算設定 */}
          <Box>
            <Typography variant="h6" gutterBottom>予算設定</Typography>
            <Box sx={{ display: 'flex', gap: 2 }}>
              <TextField
                fullWidth
                label="最小予算"
                type="number"
                value={formData.budget_min || ''}
                onChange={(e) => handleInputChange('budget_min', Number(e.target.value))}
                error={!!errors.budget_min}
                helperText={errors.budget_min}
                inputProps={{ min: 0 }}
                required
              />

              <TextField
                fullWidth
                label="最大予算"
                type="number"
                value={formData.budget_max || ''}
                onChange={(e) => handleInputChange('budget_max', Number(e.target.value))}
                error={!!errors.budget_max}
                helperText={errors.budget_max}
                inputProps={{ min: 0 }}
                required
              />
            </Box>
          </Box>

          {/* 武器の好み */}
          <Box>
            <Typography variant="h6" gutterBottom>武器の好み</Typography>
            <Box sx={{ display: 'flex', gap: 2 }}>
              <FormControl fullWidth>
                <InputLabel>好みの武器タイプ</InputLabel>
                <Select
                  value={formData.preferred_weapon_type}
                  label="好みの武器タイプ"
                  onChange={(e) => handleInputChange('preferred_weapon_type', e.target.value)}
                >
                  {weaponTypes.map(weaponType => (
                    <MenuItem key={weaponType.id} value={weaponType.id}>
                      {weaponType.name}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>

              <TextField
                fullWidth
                label="最小攻撃力要求"
                type="number"
                value={formData.min_attack_requirement || ''}
                onChange={(e) => handleInputChange('min_attack_requirement', Number(e.target.value))}
                error={!!errors.min_attack_requirement}
                helperText={errors.min_attack_requirement}
                inputProps={{ min: 0 }}
                required
              />
            </Box>
          </Box>

          {/* その他設定 */}
          <Box>
            <Typography variant="h6" gutterBottom>その他設定</Typography>
            <Box sx={{ display: 'flex', gap: 2 }}>
              <TextField
                fullWidth
                label="緊急度傾向 (1-5)"
                type="number"
                value={formData.urgency_tendency || ''}
                onChange={(e) => handleInputChange('urgency_tendency', Number(e.target.value))}
                error={!!errors.urgency_tendency}
                helperText={errors.urgency_tendency || '1: のんびり, 3: 普通, 5: 超緊急'}
                inputProps={{ min: 1, max: 5 }}
                required
              />

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