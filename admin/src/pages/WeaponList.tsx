import React, { useState } from 'react'
import {
  Box,
  Typography,
  Card,
  CardContent,
  Chip,
  Button,
  IconButton,
  Tooltip,
  CircularProgress,
  Alert,
  TextField,
  MenuItem,
  Grid,
} from '@mui/material'
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
  Add as AddIcon,
  Visibility as ViewIcon,
  AutoAwesome as MagicIcon,
} from '@mui/icons-material'
import { useGetWeaponsQuery, useGetSeasonsQuery } from '../services/api'
import { WeaponCreateDialog } from '../components/WeaponCreateDialog'
import { WeaponEditDialog } from '../components/WeaponEditDialog'
import { WeaponDeleteDialog } from '../components/WeaponDeleteDialog'
import WeaponImageGenerationDialog from '../components/WeaponImageGenerationDialog'
import Pagination from '../components/Pagination'
import SortableTable from '../components/SortableTable'
import type { SortableColumn } from '../components/SortableTable'

// モックデータ
const mockWeapons = [
  {
    id: 1,
    name: '鉄の剣',
    weapon_type: { name: '剣' },
    rarity: { name: 'Common', color_code: '#9e9e9e' },
    base_attack: 50,
    base_price: 100,
    required_level: 1,
    is_craftable: true,
    is_active: true,
  },
  {
    id: 2,
    name: '鋼鉄の剣',
    weapon_type: { name: '剣' },
    rarity: { name: 'Uncommon', color_code: '#4caf50' },
    base_attack: 75,
    base_price: 250,
    required_level: 5,
    is_craftable: true,
    is_active: true,
  },
  {
    id: 3,
    name: '炎の杖',
    weapon_type: { name: '杖' },
    rarity: { name: 'Rare', color_code: '#2196f3' },
    base_attack: 120,
    base_price: 500,
    required_level: 10,
    is_craftable: true,
    is_active: true,
  },
  {
    id: 4,
    name: 'ドラゴンスレイヤー',
    weapon_type: { name: '剣' },
    rarity: { name: 'Epic', color_code: '#9c27b0' },
    base_attack: 200,
    base_price: 1000,
    required_level: 20,
    is_craftable: false,
    is_active: true,
  },
  {
    id: 5,
    name: '氷の弓',
    weapon_type: { name: '弓' },
    rarity: { name: 'Rare', color_code: '#2196f3' },
    base_attack: 110,
    base_price: 450,
    required_level: 8,
    is_craftable: true,
    is_active: true,
  },
]

const WeaponList: React.FC = () => {
  // ページネーション関連の状態
  const [page, setPage] = useState(1)
  const [itemsPerPage, setItemsPerPage] = useState(20)
  
  // フィルター関連の状態
  const [weaponTypeFilter, setWeaponTypeFilter] = useState('')
  const [rarityFilter, setRarityFilter] = useState('')
  const [seasonFilter, setSeasonFilter] = useState('')
  
  const { data: weaponsData, isLoading, error, refetch } = useGetWeaponsQuery({
    page,
    limit: itemsPerPage,
    weapon_type_id: weaponTypeFilter || undefined,
    rarity_id: rarityFilter ? parseInt(rarityFilter) : undefined,
    season_id: seasonFilter ? parseInt(seasonFilter) : undefined,
  })

  const { data: seasonsData } = useGetSeasonsQuery({
    page: 1,
    limit: 100,
    is_active: true,
  })
  
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [isImageGenerationDialogOpen, setIsImageGenerationDialogOpen] = useState(false)
  const [selectedWeapon, setSelectedWeapon] = useState<any>(null)
  
  // APIデータまたはモックデータを使用
  const weapons = weaponsData?.data || mockWeapons
  const totalItems = weaponsData?.pagination?.total || mockWeapons.length
  const totalPages = Math.ceil(totalItems / itemsPerPage)

  // テーブルのカラム定義
  const weaponColumns: SortableColumn[] = [
    {
      id: 'id',
      label: 'ID',
      numeric: true,
      align: 'left',
    },
    {
      id: 'name',
      label: '名前',
      renderCell: (weapon) => (
        <Typography variant="body2" fontWeight="medium">
          {weapon.name}
        </Typography>
      ),
    },
    {
      id: 'weapon_type.name',
      label: '種別',
    },
    {
      id: 'rarity.name',
      label: 'レアリティ',
      renderCell: (weapon) => (
        <Chip
          label={weapon.rarity.name}
          size="small"
          sx={{
            backgroundColor: weapon.rarity.color_code,
            color: 'white',
          }}
        />
      ),
    },
    {
      id: 'season.name',
      label: 'シーズン',
      renderCell: (weapon) => (
        <Typography variant="body2">
          {weapon.season?.name || '未設定'}
        </Typography>
      ),
    },
    {
      id: 'base_attack',
      label: '攻撃力',
      numeric: true,
      align: 'right',
    },
    {
      id: 'base_price',
      label: '価格',
      numeric: true,
      align: 'right',
      renderCell: (weapon) => `${weapon.base_price}G`,
    },
    {
      id: 'image_url',
      label: '画像',
      renderCell: (weapon) => (
        weapon.image_url ? (
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <img 
              src={weapon.image_url} 
              alt={weapon.name}
              style={{ width: 32, height: 32, objectFit: 'cover', borderRadius: 4 }}
              onError={(e) => {
                (e.target as HTMLImageElement).style.display = 'none'
              }}
            />
            <Typography variant="caption" color="success.main">
              ✓
            </Typography>
          </Box>
        ) : (
          <Typography variant="caption" color="text.secondary">
            未設定
          </Typography>
        )
      ),
    },
    {
      id: 'required_level',
      label: '必要レベル',
      numeric: true,
      align: 'right',
      renderCell: (weapon) => `Lv.${weapon.required_level}`,
    },
    {
      id: 'is_craftable',
      label: '合成可能',
      sortable: false,
      renderCell: (weapon) => (
        <Chip
          label={weapon.is_craftable ? '可能' : '不可'}
          size="small"
          color={weapon.is_craftable ? 'success' : 'default'}
          variant="outlined"
        />
      ),
    },
    {
      id: 'is_active',
      label: '状態',
      sortable: false,
      renderCell: (weapon) => (
        <Chip
          label={weapon.is_active ? '有効' : '無効'}
          size="small"
          color={weapon.is_active ? 'success' : 'error'}
          variant="outlined"
        />
      ),
    },
    {
      id: 'actions',
      label: '操作',
      align: 'center',
      sortable: false,
      renderCell: (weapon) => (
        <Box>
          <Tooltip title="詳細表示">
            <IconButton
              size="small"
              onClick={(e) => {
                e.stopPropagation();
                handleView(weapon.id);
              }}
            >
              <ViewIcon />
            </IconButton>
          </Tooltip>
          <Tooltip title="編集">
            <IconButton
              size="small"
              onClick={(e) => {
                e.stopPropagation();
                handleEdit(weapon);
              }}
            >
              <EditIcon />
            </IconButton>
          </Tooltip>
          <Tooltip title="画像生成">
            <IconButton
              size="small"
              color="secondary"
              onClick={(e) => {
                e.stopPropagation();
                handleImageGeneration(weapon);
              }}
            >
              <MagicIcon />
            </IconButton>
          </Tooltip>
          <Tooltip title="削除">
            <IconButton
              size="small"
              color="error"
              onClick={(e) => {
                e.stopPropagation();
                handleDelete(weapon);
              }}
            >
              <DeleteIcon />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  const handleEdit = (weapon: any) => {
    setSelectedWeapon(weapon)
    setIsEditDialogOpen(true)
  }

  const handleDelete = (weapon: any) => {
    setSelectedWeapon(weapon)
    setIsDeleteDialogOpen(true)
  }

  const handleImageGeneration = (weapon: any) => {
    setSelectedWeapon(weapon)
    setIsImageGenerationDialogOpen(true)
  }

  const handleView = (id: number) => {
    console.log('View weapon:', id)
  }

  const handleAdd = () => {
    setIsCreateDialogOpen(true)
  }

  const handleCreateSuccess = () => {
    refetch() // データを再取得
  }

  // ページネーション関連のハンドラー
  const handlePageChange = (newPage: number) => {
    setPage(newPage)
  }

  const handleItemsPerPageChange = (newItemsPerPage: number) => {
    setItemsPerPage(newItemsPerPage)
    setPage(1) // ページサイズが変更されたら最初のページに戻る
  }

  if (isLoading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      {error && (
        <Alert severity="warning" sx={{ mb: 2 }}>
          APIに接続できません。モックデータを表示しています。
        </Alert>
      )}
      
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4" component="h1">
          武器管理
        </Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={handleAdd}
        >
          新規武器追加
        </Button>
      </Box>

      {/* フィルター */}
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            フィルター
          </Typography>
          <Grid container spacing={2}>
            <Grid item xs={12} md={3}>
              <TextField
                fullWidth
                select
                label="武器種別"
                value={weaponTypeFilter}
                onChange={(e) => setWeaponTypeFilter(e.target.value)}
                size="small"
              >
                <MenuItem value="">全て</MenuItem>
                <MenuItem value="sword">剣</MenuItem>
                <MenuItem value="bow">弓</MenuItem>
                <MenuItem value="staff">杖</MenuItem>
                <MenuItem value="axe">斧</MenuItem>
              </TextField>
            </Grid>
            <Grid item xs={12} md={3}>
              <TextField
                fullWidth
                select
                label="レアリティ"
                value={rarityFilter}
                onChange={(e) => setRarityFilter(e.target.value)}
                size="small"
              >
                <MenuItem value="">全て</MenuItem>
                <MenuItem value="1">Common</MenuItem>
                <MenuItem value="2">Uncommon</MenuItem>
                <MenuItem value="3">Rare</MenuItem>
                <MenuItem value="4">Epic</MenuItem>
                <MenuItem value="5">Legendary</MenuItem>
              </TextField>
            </Grid>
            <Grid item xs={12} md={3}>
              <TextField
                fullWidth
                select
                label="シーズン"
                value={seasonFilter}
                onChange={(e) => setSeasonFilter(e.target.value)}
                size="small"
              >
                <MenuItem value="">全て</MenuItem>
                {seasonsData?.data?.map((season) => (
                  <MenuItem key={season.id} value={season.id.toString()}>
                    {season.name}
                  </MenuItem>
                ))}
              </TextField>
            </Grid>
            <Grid item xs={12} md={3}>
              <Button
                fullWidth
                variant="outlined"
                onClick={() => {
                  setWeaponTypeFilter('');
                  setRarityFilter('');
                  setSeasonFilter('');
                }}
                size="small"
                sx={{ height: '40px' }}
              >
                フィルターをクリア
              </Button>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      {/* 統計カード */}
      <Box 
        display="flex" 
        flexWrap="wrap" 
        gap={3} 
        sx={{ mb: 4 }}
      >
        <Box flex="1 1 250px" minWidth="250px">
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                総武器数
              </Typography>
              <Typography variant="h4">
                {weapons.length}
              </Typography>
            </CardContent>
          </Card>
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                合成可能武器
              </Typography>
              <Typography variant="h4">
                {weapons.filter(w => w.is_craftable).length}
              </Typography>
            </CardContent>
          </Card>
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                平均攻撃力
              </Typography>
              <Typography variant="h4">
                {weapons.length > 0 ? Math.round(weapons.reduce((sum, w) => sum + w.base_attack, 0) / weapons.length) : 0}
              </Typography>
            </CardContent>
          </Card>
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                平均価格
              </Typography>
              <Typography variant="h4">
                {weapons.length > 0 ? Math.round(weapons.reduce((sum, w) => sum + w.base_price, 0) / weapons.length) : 0}G
              </Typography>
            </CardContent>
          </Card>
        </Box>
      </Box>

      {/* 武器一覧テーブル */}
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            武器一覧
          </Typography>
          <SortableTable
            columns={weaponColumns}
            data={weapons}
            defaultSortBy="id"
            defaultSortOrder="asc"
          />
          
          {/* ページネーション */}
          <Pagination
            page={page}
            totalPages={totalPages}
            totalItems={totalItems}
            itemsPerPage={itemsPerPage}
            onPageChange={handlePageChange}
            onItemsPerPageChange={handleItemsPerPageChange}
          />
        </CardContent>
      </Card>

      {/* 武器作成ダイアログ */}
      <WeaponCreateDialog
        open={isCreateDialogOpen}
        onClose={() => setIsCreateDialogOpen(false)}
        onSuccess={handleCreateSuccess}
      />

      {/* 武器編集ダイアログ */}
      <WeaponEditDialog
        open={isEditDialogOpen}
        weapon={selectedWeapon}
        onClose={() => {
          setIsEditDialogOpen(false)
          setSelectedWeapon(null)
        }}
        onSuccess={handleCreateSuccess}
      />

      {/* 武器削除ダイアログ */}
      <WeaponDeleteDialog
        open={isDeleteDialogOpen}
        weapon={selectedWeapon}
        onClose={() => {
          setIsDeleteDialogOpen(false)
          setSelectedWeapon(null)
        }}
        onSuccess={handleCreateSuccess}
      />

      {/* 武器画像生成ダイアログ */}
      <WeaponImageGenerationDialog
        open={isImageGenerationDialogOpen}
        weapon={selectedWeapon}
        onClose={() => {
          setIsImageGenerationDialogOpen(false)
          setSelectedWeapon(null)
        }}
        onSuccess={(imageData) => {
          console.log('Generated image:', imageData)
          // 今後、生成された画像をデータベースに保存する処理を追加
        }}
      />
    </Box>
  )
}

export default WeaponList
