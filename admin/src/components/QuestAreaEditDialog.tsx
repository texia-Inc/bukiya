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
  Slider,
  Avatar,
} from '@mui/material';
import { HexColorPicker } from 'react-colorful';
import { useUpdateQuestAreaMutation } from '../services/api';
import type { QuestAreaMaster, QuestAreaMasterUpdate } from '../types';

interface QuestAreaEditDialogProps {
  open: boolean;
  questArea: QuestAreaMaster | null;
  onClose: () => void;
  onSuccess: () => void;
}

interface QuestAreaFormData extends QuestAreaMasterUpdate {
  is_active: boolean;
}

const areaTypes = [
  { id: 'forest', name: '森林' },
  { id: 'cave', name: '洞窟' },
  { id: 'mountain', name: '山岳' },
  { id: 'ruins', name: '遺跡' },
  { id: 'desert', name: '砂漠' },
  { id: 'ocean', name: '海洋' },
  { id: 'sky', name: '空中' },
];

const difficultyLabels = {
  1: '初級',
  2: '中級',
  3: '上級',
  4: '超級',
  5: '最高級',
};

export const QuestAreaEditDialog: React.FC<QuestAreaEditDialogProps> = ({
  open,
  questArea,
  onClose,
  onSuccess,
}) => {
  const [updateQuestArea, { isLoading }] = useUpdateQuestAreaMutation();
  const [formData, setFormData] = useState<QuestAreaFormData>({
    name: '',
    area_type: 'forest',
    difficulty: 1,
    required_level: 1,
    duration_minutes: 30,
    image_url: null,
    background_color: '#4CAF50',
    description: null,
    unlock_condition: null,
    display_order: 1,
    is_active: true,
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [submitError, setSubmitError] = useState<string>('');
  const [showColorPicker, setShowColorPicker] = useState(false);

  // Initialize form data when questArea changes
  useEffect(() => {
    if (questArea) {
      setFormData({
        name: questArea.name,
        area_type: questArea.area_type,
        difficulty: questArea.difficulty,
        required_level: questArea.required_level,
        duration_minutes: questArea.duration_minutes,
        image_url: questArea.image_url,
        background_color: questArea.background_color,
        description: questArea.description,
        unlock_condition: questArea.unlock_condition,
        display_order: questArea.display_order,
        is_active: questArea.is_active,
      });
    }
  }, [questArea]);

  const handleInputChange = (field: keyof QuestAreaFormData, value: any) => {
    setFormData(prev => ({
      ...prev,
      [field]: value,
    }));
    
    // Clear error when user starts typing
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

  const handleDifficultyChange = (event: Event, newValue: number | number[]) => {
    handleInputChange('difficulty', newValue as number);
  };

  const validateForm = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!formData.name?.trim()) {
      newErrors.name = 'エリア名は必須です';
    }
    if (formData.difficulty && (formData.difficulty < 1 || formData.difficulty > 5)) {
      newErrors.difficulty = '難易度は1から5の間である必要があります';
    }
    if (formData.required_level && formData.required_level < 1) {
      newErrors.required_level = '必要レベルは1以上である必要があります';
    }
    if (formData.duration_minutes && formData.duration_minutes < 1) {
      newErrors.duration_minutes = '所要時間は1分以上である必要があります';
    }
    if (formData.display_order && formData.display_order < 1) {
      newErrors.display_order = '表示順序は1以上である必要があります';
    }
    if (!formData.background_color) {
      newErrors.background_color = '背景色は必須です';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async () => {
    setSubmitError('');
    
    if (!questArea || !validateForm()) {
      return;
    }

    try {
      // Remove is_active from the data sent to API if needed
      const { is_active, ...updateData } = formData;
      const finalData = { ...updateData, is_active };
      
      await updateQuestArea({ 
        id: questArea.id, 
        questArea: finalData 
      }).unwrap();
      onSuccess();
      handleClose();
    } catch (error: any) {
      console.error('クエストエリア更新エラー:', error);
      setSubmitError(error?.data?.message || 'クエストエリアの更新に失敗しました');
    }
  };

  const handleClose = () => {
    setErrors({});
    setSubmitError('');
    setShowColorPicker(false);
    onClose();
  };

  const formatDurationDisplay = (minutes: number) => {
    if (minutes < 60) {
      return `${minutes}分`;
    }
    const hours = Math.floor(minutes / 60);
    const remainingMinutes = minutes % 60;
    return remainingMinutes > 0 ? `${hours}時間${remainingMinutes}分` : `${hours}時間`;
  };

  if (!questArea) {
    return null;
  }

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="md"
      fullWidth
    >
      <DialogTitle>クエストエリア編集: {questArea.name}</DialogTitle>
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
                label="エリア名"
                value={formData.name}
                onChange={(e) => handleInputChange('name', e.target.value)}
                error={!!errors.name}
                helperText={errors.name}
                required
              />

              <Box sx={{ display: 'flex', gap: 2 }}>
                <FormControl fullWidth>
                  <InputLabel>エリアタイプ</InputLabel>
                  <Select
                    value={formData.area_type}
                    label="エリアタイプ"
                    onChange={(e) => handleInputChange('area_type', e.target.value)}
                  >
                    {areaTypes.map(type => (
                      <MenuItem key={type.id} value={type.id}>
                        {type.name}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>

                <TextField
                  fullWidth
                  label="表示順序"
                  type="number"
                  value={formData.display_order || ''}
                  onChange={(e) => handleInputChange('display_order', Number(e.target.value))}
                  error={!!errors.display_order}
                  helperText={errors.display_order}
                  inputProps={{ min: 1 }}
                  required
                />
              </Box>

              <TextField
                fullWidth
                label="説明"
                multiline
                rows={2}
                value={formData.description || ''}
                onChange={(e) => handleInputChange('description', e.target.value || null)}
                placeholder="エリアの説明を入力（任意）"
              />
            </Stack>
          </Box>

          {/* 難易度設定 */}
          <Box>
            <Typography variant="h6" gutterBottom>難易度設定</Typography>
            <Stack spacing={2}>
              <Box>
                <Typography variant="body2" gutterBottom>
                  難易度: {difficultyLabels[formData.difficulty as keyof typeof difficultyLabels]}
                </Typography>
                <Slider
                  value={formData.difficulty || 1}
                  onChange={handleDifficultyChange}
                  min={1}
                  max={5}
                  step={1}
                  marks={Object.entries(difficultyLabels).map(([value, label]) => ({
                    value: Number(value),
                    label,
                  }))}
                  valueLabelDisplay="off"
                />
              </Box>

              <TextField
                fullWidth
                label="必要レベル"
                type="number"
                value={formData.required_level || ''}
                onChange={(e) => handleInputChange('required_level', Number(e.target.value))}
                error={!!errors.required_level}
                helperText={errors.required_level}
                inputProps={{ min: 1 }}
                required
              />
            </Stack>
          </Box>

          {/* 時間設定 */}
          <Box>
            <Typography variant="h6" gutterBottom>時間設定</Typography>
            <TextField
              fullWidth
              label="所要時間（分）"
              type="number"
              value={formData.duration_minutes || ''}
              onChange={(e) => handleInputChange('duration_minutes', Number(e.target.value))}
              error={!!errors.duration_minutes}
              helperText={errors.duration_minutes || `表示: ${formatDurationDisplay(formData.duration_minutes || 0)}`}
              inputProps={{ min: 1 }}
              required
            />
          </Box>

          {/* 外観設定 */}
          <Box>
            <Typography variant="h6" gutterBottom>外観設定</Typography>
            <Stack spacing={2}>
              <Box>
                <Typography variant="body2" gutterBottom>
                  背景色
                </Typography>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                  <Avatar
                    sx={{
                      bgcolor: formData.background_color,
                      width: 40,
                      height: 40,
                      cursor: 'pointer',
                    }}
                    onClick={() => setShowColorPicker(!showColorPicker)}
                  >
                    {formData.name?.charAt(0) || 'A'}
                  </Avatar>
                  <Button
                    variant="outlined"
                    onClick={() => setShowColorPicker(!showColorPicker)}
                  >
                    {showColorPicker ? '閉じる' : '色を変更'}
                  </Button>
                  <Typography variant="body2" color="text.secondary">
                    {formData.background_color}
                  </Typography>
                </Box>
                {showColorPicker && (
                  <Box sx={{ mt: 2, display: 'inline-block' }}>
                    <HexColorPicker
                      color={formData.background_color}
                      onChange={(color) => handleInputChange('background_color', color)}
                    />
                  </Box>
                )}
              </Box>

              <TextField
                fullWidth
                label="画像URL"
                value={formData.image_url || ''}
                onChange={(e) => handleInputChange('image_url', e.target.value || null)}
                placeholder="https://example.com/image.png（任意）"
              />
            </Stack>
          </Box>

          {/* 解放条件 */}
          <Box>
            <Typography variant="h6" gutterBottom>解放条件</Typography>
            <TextField
              fullWidth
              label="解放条件"
              multiline
              rows={2}
              value={formData.unlock_condition || ''}
              onChange={(e) => handleInputChange('unlock_condition', e.target.value || null)}
              placeholder="例: エリア「森の入り口」をクリア（任意）"
            />
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