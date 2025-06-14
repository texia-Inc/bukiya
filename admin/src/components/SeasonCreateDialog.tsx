import React, { useState } from 'react';
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
} from '@mui/material';
import { useCreateSeasonMutation } from '../services/api';
import type { SeasonCreate } from '../types';

interface SeasonCreateDialogProps {
  open: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export const SeasonCreateDialog: React.FC<SeasonCreateDialogProps> = ({
  open,
  onClose,
  onSuccess,
}) => {
  const [formData, setFormData] = useState<SeasonCreate>({
    name: '',
    description: '',
    start_date: '',
    end_date: '',
    display_order: 1,
  });
  const [error, setError] = useState<string | null>(null);

  const [createSeason, { isLoading }] = useCreateSeasonMutation();

  const handleInputChange = (field: keyof SeasonCreate) => (
    event: React.ChangeEvent<HTMLInputElement>
  ) => {
    const value = field === 'display_order' ? parseInt(event.target.value) || 0 : event.target.value;
    setFormData((prev) => ({
      ...prev,
      [field]: value,
    }));
  };

  const handleSubmit = async () => {
    try {
      setError(null);
      
      // バリデーション
      if (!formData.name.trim()) {
        setError('シーズン名は必須です。');
        return;
      }
      
      if (!formData.start_date) {
        setError('開始日は必須です。');
        return;
      }

      if (formData.display_order < 1) {
        setError('表示順は1以上で入力してください。');
        return;
      }

      const submitData = {
        ...formData,
        description: formData.description || undefined,
        end_date: formData.end_date || undefined,
      };

      await createSeason(submitData).unwrap();
      onSuccess();
      handleClose();
    } catch (err: any) {
      console.error('シーズン作成エラー:', err);
      setError(err?.data?.message || 'シーズンの作成に失敗しました。');
    }
  };

  const handleClose = () => {
    setFormData({
      name: '',
      description: '',
      start_date: '',
      end_date: '',
      display_order: 1,
    });
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
      <DialogTitle>新規シーズン作成</DialogTitle>
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
                inputProps={{
                  min: today,
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

            <Grid item xs={12}>
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
          作成
        </Button>
      </DialogActions>
    </Dialog>
  );
};