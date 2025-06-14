import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Grid,
  Alert,
  Box,
  FormControlLabel,
  Switch,
} from '@mui/material';
import { useUpdateSeasonMutation } from '../services/api';
import type { Season, SeasonUpdate } from '../types';

interface SeasonEditDialogProps {
  open: boolean;
  season: Season | null;
  onClose: () => void;
  onSuccess: () => void;
}

export const SeasonEditDialog: React.FC<SeasonEditDialogProps> = ({
  open,
  season,
  onClose,
  onSuccess,
}) => {
  const [formData, setFormData] = useState<SeasonUpdate>({
    name: '',
    description: '',
    start_date: '',
    end_date: '',
    display_order: 1,
    is_active: true,
  });
  const [error, setError] = useState<string | null>(null);

  const [updateSeason, { isLoading }] = useUpdateSeasonMutation();

  useEffect(() => {
    if (season) {
      const formatDate = (dateString: string) => {
        return dateString.split('T')[0]; // ISO日付からYYYY-MM-DD形式に変換
      };

      setFormData({
        name: season.name,
        description: season.description || '',
        start_date: formatDate(season.start_date),
        end_date: season.end_date ? formatDate(season.end_date) : '',
        display_order: season.display_order,
        is_active: season.is_active,
      });
    }
  }, [season]);

  const handleInputChange = (field: keyof SeasonUpdate) => (
    event: React.ChangeEvent<HTMLInputElement>
  ) => {
    const value = field === 'display_order' 
      ? parseInt(event.target.value) || 0 
      : field === 'is_active'
      ? event.target.checked
      : event.target.value;
      
    setFormData((prev) => ({
      ...prev,
      [field]: value,
    }));
  };

  const handleSubmit = async () => {
    if (!season) return;

    try {
      setError(null);
      
      // バリデーション
      if (!formData.name?.trim()) {
        setError('シーズン名は必須です。');
        return;
      }
      
      if (!formData.start_date) {
        setError('開始日は必須です。');
        return;
      }

      if ((formData.display_order || 0) < 1) {
        setError('表示順は1以上で入力してください。');
        return;
      }

      const submitData = {
        ...formData,
        description: formData.description || undefined,
        end_date: formData.end_date || undefined,
      };

      await updateSeason({ id: season.id, season: submitData }).unwrap();
      onSuccess();
      handleClose();
    } catch (err: any) {
      console.error('シーズン更新エラー:', err);
      setError(err?.data?.message || 'シーズンの更新に失敗しました。');
    }
  };

  const handleClose = () => {
    setError(null);
    onClose();
  };

  const formatDateForInput = (date: Date) => {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  };

  const today = formatDateForInput(new Date());

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
      <DialogTitle>シーズン編集</DialogTitle>
      <DialogContent>
        <Box sx={{ pt: 1 }}>
          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {error}
            </Alert>
          )}

          <Grid container spacing={2}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="シーズン名"
                value={formData.name}
                onChange={handleInputChange('name')}
                required
                placeholder="例: シーズン1、春のイベント"
              />
            </Grid>
            
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="説明"
                value={formData.description}
                onChange={handleInputChange('description')}
                multiline
                rows={3}
                placeholder="シーズンの説明や特徴を入力してください"
              />
            </Grid>

            <Grid item xs={6}>
              <TextField
                fullWidth
                label="開始日"
                type="date"
                value={formData.start_date}
                onChange={handleInputChange('start_date')}
                required
                InputLabelProps={{
                  shrink: true,
                }}
              />
            </Grid>

            <Grid item xs={6}>
              <TextField
                fullWidth
                label="終了日"
                type="date"
                value={formData.end_date}
                onChange={handleInputChange('end_date')}
                InputLabelProps={{
                  shrink: true,
                }}
                inputProps={{
                  min: formData.start_date || today,
                }}
                helperText="未設定の場合は空にしてください"
              />
            </Grid>

            <Grid item xs={6}>
              <TextField
                fullWidth
                label="表示順"
                type="number"
                value={formData.display_order}
                onChange={handleInputChange('display_order')}
                required
                inputProps={{
                  min: 1,
                }}
                helperText="数字が小さいほど上位に表示されます"
              />
            </Grid>

            <Grid item xs={6}>
              <FormControlLabel
                control={
                  <Switch
                    checked={formData.is_active || false}
                    onChange={handleInputChange('is_active')}
                  />
                }
                label="有効"
              />
            </Grid>
          </Grid>
        </Box>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose}>キャンセル</Button>
        <Button
          onClick={handleSubmit}
          variant="contained"
          disabled={isLoading}
        >
          更新
        </Button>
      </DialogActions>
    </Dialog>
  );
};