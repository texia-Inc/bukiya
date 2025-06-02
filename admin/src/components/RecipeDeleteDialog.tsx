import React, { useState } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Typography,
  Alert,
  CircularProgress,
  Box,
  Chip,
  Card,
  CardContent,
  Stack,
} from '@mui/material';
import { useDeleteRecipeMutation } from '../services/api';
import type { CraftingRecipe } from '../types';

interface RecipeDeleteDialogProps {
  open: boolean;
  recipe: CraftingRecipe | null;
  onClose: () => void;
  onSuccess: () => void;
}

export const RecipeDeleteDialog: React.FC<RecipeDeleteDialogProps> = ({
  open,
  recipe,
  onClose,
  onSuccess,
}) => {
  const [deleteRecipe, { isLoading }] = useDeleteRecipeMutation();
  const [submitError, setSubmitError] = useState<string>('');

  const handleDelete = async () => {
    if (!recipe) return;
    
    setSubmitError('');
    
    try {
      await deleteRecipe(recipe.id).unwrap();
      onSuccess();
      onClose();
    } catch (error: any) {
      console.error('レシピ削除エラー:', error);
      setSubmitError(error?.data?.message || 'レシピの削除に失敗しました');
    }
  };

  const handleClose = () => {
    setSubmitError('');
    onClose();
  };

  if (!recipe) return null;

  return (
    <Dialog 
      open={open} 
      onClose={handleClose}
      maxWidth="sm"
      fullWidth
    >
      <DialogTitle sx={{ color: 'error.main' }}>
        レシピ削除の確認
      </DialogTitle>
      <DialogContent>
        {submitError && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {submitError}
          </Alert>
        )}
        
        <Typography variant="body1" sx={{ mb: 2 }}>
          以下のレシピを削除してもよろしいですか？この操作は取り消せません。
        </Typography>

        <Card 
          sx={{ 
            border: 1, 
            borderColor: 'divider', 
            bgcolor: 'grey.50'
          }}
        >
          <CardContent>
            <Typography variant="h6" sx={{ mb: 1 }}>
              {recipe.name}
            </Typography>
            
            <Box sx={{ display: 'flex', gap: 1, mb: 2, flexWrap: 'wrap' }}>
              {recipe.weapon && (
                <Chip
                  label={`対象: ${recipe.weapon.name}`}
                  size="small"
                  color="primary"
                  variant="outlined"
                />
              )}
              <Chip
                label={`成功率: ${Math.round((recipe.success_rate || 0.8) * 100)}%`}
                size="small"
                color="info"
                variant="outlined"
              />
              <Chip
                label={`必要Lv: ${recipe.required_level}`}
                size="small"
                color="secondary"
                variant="outlined"
              />
            </Box>

            <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
              {recipe.description || '説明なし'}
            </Typography>

            <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', mb: 2 }}>
              <Typography variant="body2">
                <strong>ゴールドコスト:</strong> {recipe.gold_cost}G
              </Typography>
            </Box>

            {recipe.materials && recipe.materials.length > 0 && (
              <Box>
                <Typography variant="subtitle2" sx={{ mb: 1 }}>
                  必要素材:
                </Typography>
                <Stack spacing={1}>
                  {recipe.materials.map((material, index) => (
                    <Box key={index} sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <Chip
                        label={material.material?.rarity?.name || 'Unknown'}
                        size="small"
                        sx={{
                          backgroundColor: material.material?.rarity?.color_code || '#9e9e9e',
                          color: 'white',
                          minWidth: 60,
                        }}
                      />
                      <Typography variant="body2">
                        {material.material?.name || `素材ID: ${material.material_id}`} × {material.quantity}
                      </Typography>
                    </Box>
                  ))}
                </Stack>
              </Box>
            )}
          </CardContent>
        </Card>

        <Alert severity="warning" sx={{ mt: 2 }}>
          <Typography variant="body2">
            <strong>注意:</strong> このレシピを削除すると、以下の影響があります：
          </Typography>
          <ul style={{ margin: '8px 0', paddingLeft: '20px' }}>
            <li>プレイヤーはこのレシピを使用して武器を合成できなくなります</li>
            <li>既に合成された武器には影響しません</li>
            <li>削除後は復元できません</li>
            <li>ゲームバランスに影響を与える可能性があります</li>
          </ul>
        </Alert>
      </DialogContent>
      <DialogActions>
        <Button onClick={handleClose} disabled={isLoading}>
          キャンセル
        </Button>
        <Button 
          onClick={handleDelete} 
          color="error"
          variant="contained"
          disabled={isLoading}
          startIcon={isLoading ? <CircularProgress size={20} /> : null}
        >
          {isLoading ? '削除中...' : '削除'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};
