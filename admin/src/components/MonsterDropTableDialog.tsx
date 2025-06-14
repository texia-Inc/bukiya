import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  IconButton,
  Chip,
  Box,
  Typography,
  Alert,
  CircularProgress,
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
} from '@mui/icons-material';
import {
  useGetMonsterDropsQuery,
  useDeleteMonsterDropMutation,
} from '../services/api';
import type { MonsterMaster, MonsterDropTable } from '../types';
import { MonsterDropCreateDialog } from './MonsterDropCreateDialog';
import { MonsterDropEditDialog } from './MonsterDropEditDialog';

interface MonsterDropTableDialogProps {
  open: boolean;
  monster: MonsterMaster | null;
  onClose: () => void;
}

export const MonsterDropTableDialog: React.FC<MonsterDropTableDialogProps> = ({
  open,
  monster,
  onClose,
}) => {
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedDrop, setSelectedDrop] = useState<MonsterDropTable | null>(null);

  const {
    data: dropsResponse,
    error,
    isLoading,
    refetch,
  } = useGetMonsterDropsQuery(
    { monster_id: monster?.id || 0 },
    { skip: !monster?.id }
  );

  const [deleteMonsterDrop] = useDeleteMonsterDropMutation();

  const drops = dropsResponse?.data || [];

  const handleCreate = () => {
    setCreateDialogOpen(true);
  };

  const handleEdit = (drop: MonsterDropTable) => {
    setSelectedDrop(drop);
    setEditDialogOpen(true);
  };

  const handleDelete = async (drop: MonsterDropTable) => {
    if (window.confirm(`ドロップ設定「${getItemName(drop)}」を削除しますか？`)) {
      try {
        await deleteMonsterDrop(drop.id).unwrap();
        refetch();
      } catch (error) {
        console.error('削除に失敗しました:', error);
        alert('削除に失敗しました。');
      }
    }
  };

  const getItemName = (drop: MonsterDropTable) => {
    // 新しいitem_nameフィールドがある場合はそれを使用
    if (drop.item_name) {
      return drop.item_name;
    }
    // フォールバック: 既存のリレーションデータを使用
    if (drop.drop_type === 'material' && drop.material) {
      return drop.material.name;
    }
    if (drop.drop_type === 'weapon' && drop.weapon) {
      return drop.weapon.name;
    }
    return `${drop.drop_type} ID:${drop.drop_target_id}`;
  };

  const getItemTypeLabel = (type: string) => {
    switch (type) {
      case 'material': return '素材';
      case 'weapon': return '武器';
      default: return type;
    }
  };

  const getRarityColor = (drop: MonsterDropTable) => {
    if (drop.drop_type === 'material' && drop.material?.rarity) {
      const rarity = drop.material.rarity.name.toLowerCase();
      switch (rarity) {
        case 'common': return '#9e9e9e';
        case 'uncommon': return '#4caf50';
        case 'rare': return '#2196f3';
        case 'epic': return '#9c27b0';
        case 'legendary': return '#ff9800';
        default: return '#9e9e9e';
      }
    }
    return '#9e9e9e';
  };

  return (
    <>
      <Dialog open={open} onClose={onClose} maxWidth="lg" fullWidth>
        <DialogTitle>
          ドロップテーブル管理 - {monster?.name}
        </DialogTitle>
        <DialogContent>
          <Box sx={{ mb: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <Typography variant="body2" color="text.secondary">
              このモンスターがドロップするアイテムとドロップ率を管理します。
            </Typography>
            <Button
              variant="contained"
              startIcon={<AddIcon />}
              onClick={handleCreate}
              size="small"
            >
              ドロップ追加
            </Button>
          </Box>

          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              データの取得に失敗しました。
            </Alert>
          )}

          {isLoading ? (
            <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
              <CircularProgress />
            </Box>
          ) : (
            <TableContainer component={Paper}>
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>アイテム種別</TableCell>
                    <TableCell>アイテム名</TableCell>
                    <TableCell>ドロップ率</TableCell>
                    <TableCell>数量</TableCell>
                    <TableCell>条件</TableCell>
                    <TableCell>状態</TableCell>
                    <TableCell>操作</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {drops.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={7} align="center">
                        <Typography color="text.secondary">
                          ドロップアイテムが設定されていません
                        </Typography>
                      </TableCell>
                    </TableRow>
                  ) : (
                    drops.map((drop) => (
                      <TableRow key={drop.id} hover>
                        <TableCell>
                          <Chip 
                            label={getItemTypeLabel(drop.drop_type)} 
                            size="small"
                            variant="outlined"
                          />
                        </TableCell>
                        <TableCell>
                          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                            <Box
                              sx={{
                                width: 12,
                                height: 12,
                                borderRadius: '50%',
                                backgroundColor: getRarityColor(drop),
                              }}
                            />
                            <Typography variant="body2" fontWeight="medium">
                              {getItemName(drop)}
                            </Typography>
                          </Box>
                        </TableCell>
                        <TableCell>
                          <Typography variant="body2" fontWeight="bold" color="primary">
                            {(drop.drop_rate * 100).toFixed(1)}%
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <Typography variant="body2">
                            {drop.quantity_min === drop.quantity_max 
                              ? drop.quantity_min 
                              : `${drop.quantity_min}-${drop.quantity_max}`}
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
                            {drop.required_weapon_enchant > 0 && (
                              <Typography variant="caption">
                                武器強化+{drop.required_weapon_enchant}
                              </Typography>
                            )}
                            {drop.required_adventurer_level > 0 && (
                              <Typography variant="caption">
                                冒険者Lv.{drop.required_adventurer_level}
                              </Typography>
                            )}
                            {drop.required_weapon_enchant === 0 && drop.required_adventurer_level === 0 && (
                              <Typography variant="caption" color="text.secondary">
                                条件なし
                              </Typography>
                            )}
                          </Box>
                        </TableCell>
                        <TableCell>
                          <Chip
                            label={drop.is_active ? '有効' : '無効'}
                            size="small"
                            color={drop.is_active ? 'success' : 'default'}
                          />
                        </TableCell>
                        <TableCell>
                          <Box sx={{ display: 'flex', gap: 0.5 }}>
                            <IconButton
                              size="small"
                              onClick={() => handleEdit(drop)}
                              color="primary"
                            >
                              <EditIcon />
                            </IconButton>
                            <IconButton
                              size="small"
                              onClick={() => handleDelete(drop)}
                              color="error"
                            >
                              <DeleteIcon />
                            </IconButton>
                          </Box>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          )}

          {drops.length > 0 && (
            <Alert severity="info" sx={{ mt: 2 }}>
              <Typography variant="body2">
                <strong>合計ドロップ率: {(drops.reduce((sum, drop) => sum + drop.drop_rate, 0) * 100).toFixed(1)}%</strong>
                {drops.reduce((sum, drop) => sum + drop.drop_rate, 0) > 1 && (
                  <span style={{ color: '#f57c00' }}>
                    {' '}(100%を超えています。ドロップ率を調整してください)
                  </span>
                )}
              </Typography>
            </Alert>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={onClose}>閉じる</Button>
        </DialogActions>
      </Dialog>

      {/* ドロップアイテム作成ダイアログ */}
      <MonsterDropCreateDialog
        open={createDialogOpen}
        monster={monster}
        onClose={() => setCreateDialogOpen(false)}
        onSuccess={() => {
          refetch();
          setCreateDialogOpen(false);
        }}
      />

      {/* ドロップアイテム編集ダイアログ */}
      <MonsterDropEditDialog
        open={editDialogOpen}
        drop={selectedDrop}
        onClose={() => {
          setEditDialogOpen(false);
          setSelectedDrop(null);
        }}
        onSuccess={() => {
          refetch();
          setEditDialogOpen(false);
          setSelectedDrop(null);
        }}
      />
    </>
  );
};