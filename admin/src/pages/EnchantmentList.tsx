import React, { useState, useEffect } from 'react';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  Button,
  TextField,
  MenuItem,
  Grid,
  Tabs,
  Tab,
  IconButton,
  Tooltip,
  Alert,
  Snackbar,
} from '@mui/material';
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  Refresh as RefreshIcon,
} from '@mui/icons-material';
import { enchantmentApi, type EnchantmentType, type EnchantmentMaterial } from '../services/enchantmentApi';
import EnchantmentTypeDialog from '../components/EnchantmentTypeDialog';
import EnchantmentMaterialDialog from '../components/EnchantmentMaterialDialog';
import EnchantmentDeleteDialog from '../components/EnchantmentDeleteDialog';

const EnchantmentList: React.FC = () => {
  const [tabValue, setTabValue] = useState(0);
  const [enchantmentTypes, setEnchantmentTypes] = useState<EnchantmentType[]>([]);
  const [materials, setMaterials] = useState<EnchantmentMaterial[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [effectTypeFilter, setEffectTypeFilter] = useState('');
  const [rarityFilter, setRarityFilter] = useState('');

  // ダイアログの状態管理
  const [typeDialogOpen, setTypeDialogOpen] = useState(false);
  const [materialDialogOpen, setMaterialDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [editingType, setEditingType] = useState<EnchantmentType | null>(null);
  const [editingMaterial, setEditingMaterial] = useState<EnchantmentMaterial | null>(null);
  const [deletingItem, setDeletingItem] = useState<{ id: number; name: string; type: 'type' | 'material' } | null>(null);
  const [dialogLoading, setDialogLoading] = useState(false);

  // 通知の状態管理
  const [snackbar, setSnackbar] = useState<{
    open: boolean;
    message: string;
    severity: 'success' | 'error' | 'warning' | 'info';
  }>({
    open: false,
    message: '',
    severity: 'success',
  });

  const effectTypes = [
    { value: '', label: 'すべて' },
    { value: 'attack', label: '攻撃力' },
    { value: 'defense', label: '防御力' },
    { value: 'speed', label: '速度' },
    { value: 'critical', label: 'クリティカル' },
    { value: 'accuracy', label: '命中' },
    { value: 'durability', label: '耐久' },
  ];

  const rarityTypes = [
    { value: '', label: 'すべて' },
    { value: 'common', label: 'コモン' },
    { value: 'uncommon', label: 'アンコモン' },
    { value: 'rare', label: 'レア' },
    { value: 'epic', label: 'エピック' },
    { value: 'legendary', label: 'レジェンダリー' },
  ];

  const showSnackbar = (message: string, severity: 'success' | 'error' | 'warning' | 'info' = 'success') => {
    setSnackbar({ open: true, message, severity });
  };

  const fetchEnchantmentTypes = async () => {
    try {
      setLoading(true);
      const response = await enchantmentApi.getEnchantmentTypes({
        search: searchTerm || undefined,
        effect_type: effectTypeFilter || undefined,
      });
      if (response.success) {
        setEnchantmentTypes(response.data);
      }
    } catch (error) {
      console.error('エンチャントタイプの取得に失敗しました:', error);
      showSnackbar('エンチャントタイプの取得に失敗しました', 'error');
    } finally {
      setLoading(false);
    }
  };

  const fetchMaterials = async () => {
    try {
      setLoading(true);
      const response = await enchantmentApi.getEnchantmentMaterials({
        search: searchTerm || undefined,
        rarity: rarityFilter || undefined,
      });
      if (response.success) {
        setMaterials(response.data);
      }
    } catch (error) {
      console.error('エンチャント素材の取得に失敗しました:', error);
      showSnackbar('エンチャント素材の取得に失敗しました', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (tabValue === 0) {
      fetchEnchantmentTypes();
    } else {
      fetchMaterials();
    }
  }, [tabValue, searchTerm, effectTypeFilter, rarityFilter]);

  const handleTabChange = (event: React.SyntheticEvent, newValue: number) => {
    setTabValue(newValue);
    setSearchTerm('');
    setEffectTypeFilter('');
    setRarityFilter('');
  };

  // エンチャントタイプのCRUD操作
  const handleCreateType = () => {
    setEditingType(null);
    setTypeDialogOpen(true);
  };

  const handleEditType = (type: EnchantmentType) => {
    setEditingType(type);
    setTypeDialogOpen(true);
  };

  const handleSaveType = async (data: EnchantmentType) => {
    try {
      setDialogLoading(true);
      let response;
      
      if (editingType?.id) {
        // 更新
        response = await enchantmentApi.updateEnchantmentType(editingType.id, data);
        if (response.success) {
          showSnackbar('エンチャントタイプを更新しました');
          fetchEnchantmentTypes();
          setTypeDialogOpen(false);
        }
      } else {
        // 作成
        response = await enchantmentApi.createEnchantmentType(data);
        if (response.success) {
          showSnackbar('エンチャントタイプを作成しました');
          fetchEnchantmentTypes();
          setTypeDialogOpen(false);
        }
      }
    } catch (error) {
      console.error('エンチャントタイプの保存に失敗しました:', error);
      showSnackbar('エンチャントタイプの保存に失敗しました', 'error');
    } finally {
      setDialogLoading(false);
    }
  };

  // エンチャント素材のCRUD操作
  const handleCreateMaterial = () => {
    setEditingMaterial(null);
    setMaterialDialogOpen(true);
  };

  const handleEditMaterial = (material: EnchantmentMaterial) => {
    setEditingMaterial(material);
    setMaterialDialogOpen(true);
  };

  const handleSaveMaterial = async (data: EnchantmentMaterial) => {
    try {
      setDialogLoading(true);
      let response;
      
      if (editingMaterial?.id) {
        // 更新
        response = await enchantmentApi.updateEnchantmentMaterial(editingMaterial.id, data);
        if (response.success) {
          showSnackbar('エンチャント素材を更新しました');
          fetchMaterials();
          setMaterialDialogOpen(false);
        }
      } else {
        // 作成
        response = await enchantmentApi.createEnchantmentMaterial(data);
        if (response.success) {
          showSnackbar('エンチャント素材を作成しました');
          fetchMaterials();
          setMaterialDialogOpen(false);
        }
      }
    } catch (error) {
      console.error('エンチャント素材の保存に失敗しました:', error);
      showSnackbar('エンチャント素材の保存に失敗しました', 'error');
    } finally {
      setDialogLoading(false);
    }
  };

  // 削除操作
  const handleDeleteClick = (id: number, name: string, type: 'type' | 'material') => {
    setDeletingItem({ id, name, type });
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    if (!deletingItem) return;

    try {
      setDialogLoading(true);
      let response;

      if (deletingItem.type === 'type') {
        response = await enchantmentApi.deleteEnchantmentType(deletingItem.id);
        if (response.success) {
          showSnackbar('エンチャントタイプを削除しました');
          fetchEnchantmentTypes();
        }
      } else {
        response = await enchantmentApi.deleteEnchantmentMaterial(deletingItem.id);
        if (response.success) {
          showSnackbar('エンチャント素材を削除しました');
          fetchMaterials();
        }
      }
      
      setDeleteDialogOpen(false);
      setDeletingItem(null);
    } catch (error) {
      console.error('削除に失敗しました:', error);
      showSnackbar('削除に失敗しました', 'error');
    } finally {
      setDialogLoading(false);
    }
  };

  const getEffectTypeLabel = (effectType: string) => {
    const type = effectTypes.find(t => t.value === effectType);
    return type ? type.label : effectType;
  };

  const getRarityLabel = (rarity: string) => {
    const type = rarityTypes.find(t => t.value === rarity);
    return type ? type.label : rarity;
  };

  const getRarityColor = (rarity: string) => {
    switch (rarity) {
      case 'common': return 'default';
      case 'uncommon': return 'primary';
      case 'rare': return 'secondary';
      case 'epic': return 'warning';
      case 'legendary': return 'error';
      default: return 'default';
    }
  };

  const formatPercentage = (value: number) => {
    return `${(value * 100).toFixed(1)}%`;
  };

  const formatCurrency = (value: number) => {
    return value.toLocaleString();
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom>
        エンチャント管理
      </Typography>

      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Tabs value={tabValue} onChange={handleTabChange} sx={{ mb: 2 }}>
            <Tab label="エンチャントタイプ" />
            <Tab label="エンチャント素材" />
          </Tabs>

          <Grid container spacing={2} sx={{ mb: 2 }}>
            <Grid item xs={12} md={4}>
              <TextField
                fullWidth
                label="検索"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="名前で検索..."
              />
            </Grid>
            {tabValue === 0 ? (
              <Grid item xs={12} md={4}>
                <TextField
                  fullWidth
                  select
                  label="効果タイプ"
                  value={effectTypeFilter}
                  onChange={(e) => setEffectTypeFilter(e.target.value)}
                >
                  {effectTypes.map((option) => (
                    <MenuItem key={option.value} value={option.value}>
                      {option.label}
                    </MenuItem>
                  ))}
                </TextField>
              </Grid>
            ) : (
              <Grid item xs={12} md={4}>
                <TextField
                  fullWidth
                  select
                  label="レアリティ"
                  value={rarityFilter}
                  onChange={(e) => setRarityFilter(e.target.value)}
                >
                  {rarityTypes.map((option) => (
                    <MenuItem key={option.value} value={option.value}>
                      {option.label}
                    </MenuItem>
                  ))}
                </TextField>
              </Grid>
            )}
            <Grid item xs={12} md={4}>
              <Box sx={{ display: 'flex', gap: 1 }}>
                <Button
                  variant="contained"
                  startIcon={<AddIcon />}
                  onClick={tabValue === 0 ? handleCreateType : handleCreateMaterial}
                >
                  新規作成
                </Button>
                <IconButton
                  onClick={() => {
                    if (tabValue === 0) {
                      fetchEnchantmentTypes();
                    } else {
                      fetchMaterials();
                    }
                  }}
                >
                  <RefreshIcon />
                </IconButton>
              </Box>
            </Grid>
          </Grid>

          {tabValue === 0 ? (
            <TableContainer component={Paper}>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>ID</TableCell>
                    <TableCell>名前</TableCell>
                    <TableCell>効果タイプ</TableCell>
                    <TableCell>効果値</TableCell>
                    <TableCell>最大レベル</TableCell>
                    <TableCell>基本成功率</TableCell>
                    <TableCell>基本コスト</TableCell>
                    <TableCell>状態</TableCell>
                    <TableCell>操作</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {enchantmentTypes.map((type) => (
                    <TableRow key={type.id}>
                      <TableCell>{type.id}</TableCell>
                      <TableCell>
                        <Box>
                          <Typography variant="body2" fontWeight="bold">
                            {type.name}
                          </Typography>
                          <Typography variant="caption" color="text.secondary">
                            {type.description}
                          </Typography>
                        </Box>
                      </TableCell>
                      <TableCell>
                        <Chip
                          label={getEffectTypeLabel(type.effect_type)}
                          size="small"
                          color="primary"
                        />
                      </TableCell>
                      <TableCell>{type.effect_value}</TableCell>
                      <TableCell>{type.max_level}</TableCell>
                      <TableCell>{formatPercentage(type.base_success_rate)}</TableCell>
                      <TableCell>{formatCurrency(type.base_cost)}G</TableCell>
                      <TableCell>
                        <Chip
                          label={type.is_active ? '有効' : '無効'}
                          color={type.is_active ? 'success' : 'default'}
                          size="small"
                        />
                      </TableCell>
                      <TableCell>
                        <Box sx={{ display: 'flex', gap: 1 }}>
                          <Tooltip title="編集">
                            <IconButton
                              size="small"
                              onClick={() => handleEditType(type)}
                            >
                              <EditIcon />
                            </IconButton>
                          </Tooltip>
                          <Tooltip title="削除">
                            <IconButton
                              size="small"
                              color="error"
                              onClick={() => handleDeleteClick(type.id!, type.name, 'type')}
                            >
                              <DeleteIcon />
                            </IconButton>
                          </Tooltip>
                        </Box>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          ) : (
            <TableContainer component={Paper}>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>ID</TableCell>
                    <TableCell>名前</TableCell>
                    <TableCell>レアリティ</TableCell>
                    <TableCell>効果タイプ</TableCell>
                    <TableCell>成功率ボーナス</TableCell>
                    <TableCell>コスト倍率</TableCell>
                    <TableCell>最大所持数</TableCell>
                    <TableCell>状態</TableCell>
                    <TableCell>操作</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {materials.map((material) => (
                    <TableRow key={material.id}>
                      <TableCell>{material.id}</TableCell>
                      <TableCell>
                        <Box>
                          <Typography variant="body2" fontWeight="bold">
                            {material.name}
                          </Typography>
                          <Typography variant="caption" color="text.secondary">
                            {material.description}
                          </Typography>
                        </Box>
                      </TableCell>
                      <TableCell>
                        <Chip
                          label={getRarityLabel(material.rarity)}
                          size="small"
                          color={getRarityColor(material.rarity) as any}
                        />
                      </TableCell>
                      <TableCell>
                        {material.effect_type ? (
                          <Chip
                            label={getEffectTypeLabel(material.effect_type)}
                            size="small"
                            variant="outlined"
                          />
                        ) : (
                          <Typography variant="body2" color="text.secondary">
                            汎用
                          </Typography>
                        )}
                      </TableCell>
                      <TableCell>
                        {material.success_rate_bonus > 0 
                          ? `+${formatPercentage(material.success_rate_bonus)}`
                          : '-'
                        }
                      </TableCell>
                      <TableCell>×{material.cost_multiplier}</TableCell>
                      <TableCell>{material.max_stack.toLocaleString()}</TableCell>
                      <TableCell>
                        <Chip
                          label={material.is_active ? '有効' : '無効'}
                          color={material.is_active ? 'success' : 'default'}
                          size="small"
                        />
                      </TableCell>
                      <TableCell>
                        <Box sx={{ display: 'flex', gap: 1 }}>
                          <Tooltip title="編集">
                            <IconButton
                              size="small"
                              onClick={() => handleEditMaterial(material)}
                            >
                              <EditIcon />
                            </IconButton>
                          </Tooltip>
                          <Tooltip title="削除">
                            <IconButton
                              size="small"
                              color="error"
                              onClick={() => handleDeleteClick(material.id!, material.name, 'material')}
                            >
                              <DeleteIcon />
                            </IconButton>
                          </Tooltip>
                        </Box>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          )}
        </CardContent>
      </Card>

      {/* エンチャントタイプダイアログ */}
      <EnchantmentTypeDialog
        open={typeDialogOpen}
        onClose={() => setTypeDialogOpen(false)}
        onSave={handleSaveType}
        enchantmentType={editingType}
        loading={dialogLoading}
      />

      {/* エンチャント素材ダイアログ */}
      <EnchantmentMaterialDialog
        open={materialDialogOpen}
        onClose={() => setMaterialDialogOpen(false)}
        onSave={handleSaveMaterial}
        material={editingMaterial}
        loading={dialogLoading}
      />

      {/* 削除確認ダイアログ */}
      <EnchantmentDeleteDialog
        open={deleteDialogOpen}
        onClose={() => setDeleteDialogOpen(false)}
        onConfirm={handleDeleteConfirm}
        itemName={deletingItem?.name || ''}
        itemType={deletingItem?.type || 'type'}
        loading={dialogLoading}
      />

      {/* 通知スナックバー */}
      <Snackbar
        open={snackbar.open}
        autoHideDuration={6000}
        onClose={() => setSnackbar(prev => ({ ...prev, open: false }))}
      >
        <Alert
          onClose={() => setSnackbar(prev => ({ ...prev, open: false }))}
          severity={snackbar.severity}
          sx={{ width: '100%' }}
        >
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
  );
};

export default EnchantmentList;
