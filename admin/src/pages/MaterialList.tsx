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
} from '@mui/material'
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
  Add as AddIcon,
  Visibility as ViewIcon,
} from '@mui/icons-material'
import { useGetMaterialsQuery } from '../services/api'
import { MaterialCreateDialog } from '../components/MaterialCreateDialog'
import { MaterialEditDialog } from '../components/MaterialEditDialog'
import { MaterialDeleteDialog } from '../components/MaterialDeleteDialog'
import Pagination from '../components/Pagination'
import SortableTable from '../components/SortableTable'
import type { SortableColumn } from '../components/SortableTable'

// モックデータ
const mockMaterials = [
  {
    id: 1,
    name: '鉄鉱石',
    description: '武器作成に使用される基本的な鉱石',
    rarity: { name: 'Common', color_code: '#9e9e9e' },
    base_price: 10,
    max_stack: 99,
    is_active: true,
  },
  {
    id: 2,
    name: '魔法の水晶',
    description: 'エンチャントに使用される神秘的な水晶',
    rarity: { name: 'Rare', color_code: '#2196f3' },
    base_price: 100,
    max_stack: 50,
    is_active: true,
  },
  {
    id: 3,
    name: 'ドラゴンの鱗',
    description: '伝説の武器作成に必要な希少素材',
    rarity: { name: 'Epic', color_code: '#9c27b0' },
    base_price: 500,
    max_stack: 10,
    is_active: true,
  },
  {
    id: 4,
    name: '古代の木材',
    description: '特殊な杖の作成に使用される古代の木',
    rarity: { name: 'Uncommon', color_code: '#4caf50' },
    base_price: 50,
    max_stack: 99,
    is_active: true,
  },
  {
    id: 5,
    name: '氷の欠片',
    description: '氷属性武器の作成に必要な氷の欠片',
    rarity: { name: 'Rare', color_code: '#2196f3' },
    base_price: 80,
    max_stack: 99,
    is_active: true,
  },
]

const MaterialList: React.FC = () => {
  // ページネーション関連の状態
  const [page, setPage] = useState(1)
  const [itemsPerPage, setItemsPerPage] = useState(20)
  
  const { data: materialsData, isLoading, error, refetch } = useGetMaterialsQuery({
    page,
    limit: itemsPerPage,
  })
  
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [selectedMaterial, setSelectedMaterial] = useState<any>(null)
  
  // APIデータまたはモックデータを使用
  const materials = materialsData?.data || mockMaterials
  const totalItems = materialsData?.pagination?.total || mockMaterials.length
  const totalPages = Math.ceil(totalItems / itemsPerPage)

  // テーブルのカラム定義
  const materialColumns: SortableColumn[] = [
    {
      id: 'id',
      label: 'ID',
      numeric: true,
      align: 'left',
    },
    {
      id: 'name',
      label: '名前',
      renderCell: (material) => (
        <Typography variant="body2" fontWeight="medium">
          {material.name}
        </Typography>
      ),
    },
    {
      id: 'description',
      label: '説明',
      renderCell: (material) => (
        <Typography variant="body2" color="textSecondary">
          {material.description}
        </Typography>
      ),
    },
    {
      id: 'rarity.name',
      label: 'レアリティ',
      renderCell: (material) => (
        <Chip
          label={material.rarity.name}
          size="small"
          sx={{
            backgroundColor: material.rarity.color_code,
            color: 'white',
          }}
        />
      ),
    },
    {
      id: 'base_price',
      label: '価格',
      numeric: true,
      align: 'right',
      renderCell: (material) => `${material.base_price}G`,
    },
    {
      id: 'max_stack',
      label: '最大スタック',
      numeric: true,
      align: 'right',
      renderCell: (material) => material.max_stack || 99,
    },
    {
      id: 'is_active',
      label: '状態',
      sortable: false,
      renderCell: (material) => (
        <Chip
          label={material.is_active ? '有効' : '無効'}
          size="small"
          color={material.is_active ? 'success' : 'error'}
          variant="outlined"
        />
      ),
    },
    {
      id: 'actions',
      label: '操作',
      align: 'center',
      sortable: false,
      renderCell: (material) => (
        <Box>
          <Tooltip title="詳細表示">
            <IconButton
              size="small"
              onClick={(e) => {
                e.stopPropagation();
                handleView(material.id);
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
                handleEdit(material);
              }}
            >
              <EditIcon />
            </IconButton>
          </Tooltip>
          <Tooltip title="削除">
            <IconButton
              size="small"
              color="error"
              onClick={(e) => {
                e.stopPropagation();
                handleDelete(material);
              }}
            >
              <DeleteIcon />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  const handleEdit = (material: any) => {
    setSelectedMaterial(material)
    setIsEditDialogOpen(true)
  }

  const handleDelete = (material: any) => {
    setSelectedMaterial(material)
    setIsDeleteDialogOpen(true)
  }

  const handleView = (id: number) => {
    console.log('View material:', id)
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
          素材管理
        </Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={handleAdd}
        >
          新規素材追加
        </Button>
      </Box>

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
                総素材数
              </Typography>
              <Typography variant="h4">
                {materials.length}
              </Typography>
            </CardContent>
          </Card>
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                有効素材
              </Typography>
              <Typography variant="h4">
                {materials.filter(m => m.is_active).length}
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
                {materials.length > 0 ? Math.round(materials.reduce((sum, m) => sum + m.base_price, 0) / materials.length) : 0}G
              </Typography>
            </CardContent>
          </Card>
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                希少素材
              </Typography>
              <Typography variant="h4">
                {materials.filter(m => m.rarity.name === 'Rare' || m.rarity.name === 'Epic').length}
              </Typography>
            </CardContent>
          </Card>
        </Box>
      </Box>

      {/* 素材一覧テーブル */}
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            素材一覧
          </Typography>
          <SortableTable
            columns={materialColumns}
            data={materials}
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

      {/* 素材作成ダイアログ */}
      <MaterialCreateDialog
        open={isCreateDialogOpen}
        onClose={() => setIsCreateDialogOpen(false)}
        onSuccess={handleCreateSuccess}
      />

      {/* 素材編集ダイアログ */}
      <MaterialEditDialog
        open={isEditDialogOpen}
        material={selectedMaterial}
        onClose={() => {
          setIsEditDialogOpen(false)
          setSelectedMaterial(null)
        }}
        onSuccess={handleCreateSuccess}
      />

      {/* 素材削除ダイアログ */}
      <MaterialDeleteDialog
        open={isDeleteDialogOpen}
        material={selectedMaterial}
        onClose={() => {
          setIsDeleteDialogOpen(false)
          setSelectedMaterial(null)
        }}
        onSuccess={handleCreateSuccess}
      />
    </Box>
  )
}

export default MaterialList
