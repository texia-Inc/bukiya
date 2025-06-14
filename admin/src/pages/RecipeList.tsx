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
  Stack,
} from '@mui/material'
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
  Add as AddIcon,
  Visibility as ViewIcon,
} from '@mui/icons-material'
import { useGetRecipesQuery } from '../services/api'
import { RecipeCreateDialog } from '../components/RecipeCreateDialog'
import { RecipeEditDialog } from '../components/RecipeEditDialog'
import { RecipeDeleteDialog } from '../components/RecipeDeleteDialog'
import Pagination from '../components/Pagination'
import SortableTable from '../components/SortableTable'
import type { SortableColumn } from '../components/SortableTable'

// モックデータ
const mockRecipes = [
  {
    id: 1,
    name: '鉄の剣レシピ',
    description: '基本的な鉄の剣を作成するレシピ',
    weapon: { 
      id: 1,
      name: '鉄の剣', 
      rarity: { name: 'Common', color_code: '#9e9e9e' },
      weapon_type: { name: '剣' }
    },
    materials: [
      { material_id: 1, material: { name: '鉄鉱石', rarity: { name: 'Common', color_code: '#9e9e9e' } }, quantity: 3 },
      { material_id: 4, material: { name: '古代の木材', rarity: { name: 'Uncommon', color_code: '#4caf50' } }, quantity: 1 },
    ],
    gold_cost: 100,
    success_rate: 0.95,
    required_level: 1,
    is_active: true,
  },
  {
    id: 2,
    name: '炎の杖レシピ',
    description: '魔法の力を宿した炎の杖のレシピ',
    weapon: { 
      id: 3,
      name: '炎の杖', 
      rarity: { name: 'Rare', color_code: '#2196f3' },
      weapon_type: { name: '杖' }
    },
    materials: [
      { material_id: 2, material: { name: '魔法の水晶', rarity: { name: 'Rare', color_code: '#2196f3' } }, quantity: 2 },
      { material_id: 4, material: { name: '古代の木材', rarity: { name: 'Uncommon', color_code: '#4caf50' } }, quantity: 2 },
    ],
    gold_cost: 500,
    success_rate: 0.75,
    required_level: 10,
    is_active: true,
  },
  {
    id: 3,
    name: 'ドラゴンスレイヤーレシピ',
    description: '伝説の武器ドラゴンスレイヤーのレシピ',
    weapon: { 
      id: 4,
      name: 'ドラゴンスレイヤー', 
      rarity: { name: 'Epic', color_code: '#9c27b0' },
      weapon_type: { name: '剣' }
    },
    materials: [
      { material_id: 3, material: { name: 'ドラゴンの鱗', rarity: { name: 'Epic', color_code: '#9c27b0' } }, quantity: 5 },
      { material_id: 2, material: { name: '魔法の水晶', rarity: { name: 'Rare', color_code: '#2196f3' } }, quantity: 3 },
      { material_id: 1, material: { name: '鉄鉱石', rarity: { name: 'Common', color_code: '#9e9e9e' } }, quantity: 10 },
    ],
    gold_cost: 2000,
    success_rate: 0.3,
    required_level: 20,
    is_active: true,
  },
  {
    id: 4,
    name: '氷の弓レシピ',
    description: '氷の力を宿した弓のレシピ',
    weapon: { 
      id: 5,
      name: '氷の弓', 
      rarity: { name: 'Rare', color_code: '#2196f3' },
      weapon_type: { name: '弓' }
    },
    materials: [
      { material_id: 5, material: { name: '氷の欠片', rarity: { name: 'Rare', color_code: '#2196f3' } }, quantity: 4 },
      { material_id: 4, material: { name: '古代の木材', rarity: { name: 'Uncommon', color_code: '#4caf50' } }, quantity: 3 },
    ],
    gold_cost: 450,
    success_rate: 0.8,
    required_level: 8,
    is_active: true,
  },
]

const RecipeList: React.FC = () => {
  // ページネーション関連の状態
  const [page, setPage] = useState(1)
  const [itemsPerPage, setItemsPerPage] = useState(20)
  
  const { data: recipesData, isLoading, error, refetch } = useGetRecipesQuery({
    page,
    limit: itemsPerPage,
  })
  
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [selectedRecipe, setSelectedRecipe] = useState<any>(null)
  
  // APIデータを優先、エラー時のみモックデータ使用
  const recipes = error ? mockRecipes : (recipesData?.data || [])
  const totalItems = error ? mockRecipes.length : (recipesData?.pagination?.total || 0)
  const totalPages = Math.ceil(totalItems / itemsPerPage)
  
  // デバッグ用ログ
  React.useEffect(() => {
    console.log('RecipeList Debug:', {
      isLoading,
      error,
      hasRecipesData: !!recipesData,
      recipesCount: recipes.length,
      usingMockData: !!error
    });
    
    if (recipesData?.data) {
      const problemRecipes = recipesData.data.filter(r => 
        r.name?.includes('クリスタルスタッフ') || r.name?.includes('マジックソード')
      );
      console.log('Problem recipes from API:', problemRecipes);
    }
  }, [isLoading, error, recipesData, recipes]);

  // テーブルのカラム定義
  const recipeColumns: SortableColumn[] = [
    {
      id: 'id',
      label: 'ID',
      numeric: true,
      align: 'left',
    },
    {
      id: 'name',
      label: 'レシピ名',
      renderCell: (recipe) => (
        <Box>
          <Typography variant="body2" fontWeight="medium">
            {recipe.name}
          </Typography>
          <Typography variant="caption" color="textSecondary">
            {recipe.description}
          </Typography>
        </Box>
      ),
    },
    {
      id: 'weapon.name',
      label: '生成武器',
      renderCell: (recipe) => (
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <Chip
            label={recipe.weapon.rarity.name}
            size="small"
            sx={{
              backgroundColor: recipe.weapon.rarity.color_code,
              color: 'white',
            }}
          />
          <Box>
            <Typography variant="body2" fontWeight="medium">
              {recipe.weapon.name}
            </Typography>
            <Typography variant="caption" color="textSecondary">
              {recipe.weapon.weapon_type.name}
            </Typography>
          </Box>
        </Box>
      ),
    },
    {
      id: 'materials',
      label: '必要素材',
      sortable: false,
      renderCell: (recipe) => {
        // デバッグ用ログ
        if (recipe.name?.includes('クリスタルスタッフ') || recipe.name?.includes('マジックソード')) {
          console.log(`DEBUG: Recipe ${recipe.name}:`, {
            materials: recipe.materials,
            materialsLength: recipe.materials?.length,
            firstMaterial: recipe.materials?.[0]
          });
        }
        
        return (
          <Stack spacing={0.5}>
            {recipe.materials?.slice(0, 3).map((mat: any, index: number) => (
              <Box key={index} sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Chip
                  label={mat.material?.rarity?.name || 'Unknown'}
                  size="small"
                  sx={{
                    backgroundColor: mat.material?.rarity?.color_code || '#gray',
                    color: 'white',
                    minWidth: 60,
                  }}
                />
                <Typography variant="caption">
                  {mat.material?.name || 'Unknown'} x{mat.quantity}
                </Typography>
              </Box>
            ))}
            {recipe.materials && recipe.materials.length > 3 && (
              <Typography variant="caption" color="textSecondary">
                他{recipe.materials.length - 3}個...
              </Typography>
            )}
          </Stack>
        );
      },
    },
    {
      id: 'gold_cost',
      label: 'コスト',
      numeric: true,
      align: 'right',
      renderCell: (recipe) => `${recipe.gold_cost}G`,
    },
    {
      id: 'success_rate',
      label: '成功率',
      numeric: true,
      align: 'right',
      renderCell: (recipe) => `${(recipe.success_rate * 100).toFixed(0)}%`,
    },
    {
      id: 'required_level',
      label: '必要Lv',
      numeric: true,
      align: 'right',
      renderCell: (recipe) => `Lv.${recipe.required_level}`,
    },
    {
      id: 'is_active',
      label: '状態',
      sortable: false,
      renderCell: (recipe) => (
        <Chip
          label={recipe.is_active ? '有効' : '無効'}
          size="small"
          color={recipe.is_active ? 'success' : 'error'}
          variant="outlined"
        />
      ),
    },
    {
      id: 'actions',
      label: '操作',
      align: 'center',
      sortable: false,
      renderCell: (recipe) => (
        <Box>
          <Tooltip title="詳細表示">
            <IconButton
              size="small"
              onClick={(e) => {
                e.stopPropagation();
                handleView(recipe.id);
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
                handleEdit(recipe);
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
                handleDelete(recipe);
              }}
            >
              <DeleteIcon />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  const handleEdit = (recipe: any) => {
    setSelectedRecipe(recipe)
    setIsEditDialogOpen(true)
  }

  const handleDelete = (recipe: any) => {
    setSelectedRecipe(recipe)
    setIsDeleteDialogOpen(true)
  }

  const handleView = (id: number) => {
    console.log('View recipe:', id)
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
          レシピ管理
        </Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={handleAdd}
        >
          新規レシピ追加
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
                総レシピ数
              </Typography>
              <Typography variant="h4">
                {recipes.length}
              </Typography>
            </CardContent>
          </Card>
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                有効レシピ
              </Typography>
              <Typography variant="h4">
                {recipes.filter(r => r.is_active).length}
              </Typography>
            </CardContent>
          </Card>
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                平均成功率
              </Typography>
              <Typography variant="h4">
                {recipes.length > 0 ? Math.round(recipes.reduce((sum, r) => sum + (r.success_rate * 100), 0) / recipes.length) : 0}%
              </Typography>
            </CardContent>
          </Card>
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                高難度レシピ
              </Typography>
              <Typography variant="h4">
                {recipes.filter(r => r.success_rate < 0.5).length}
              </Typography>
            </CardContent>
          </Card>
        </Box>
      </Box>

      {/* レシピ一覧テーブル */}
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            レシピ一覧
          </Typography>
          <SortableTable
            columns={recipeColumns}
            data={recipes}
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

      {/* レシピ作成ダイアログ */}
      <RecipeCreateDialog
        open={isCreateDialogOpen}
        onClose={() => setIsCreateDialogOpen(false)}
        onSuccess={handleCreateSuccess}
      />

      {/* レシピ編集ダイアログ */}
      <RecipeEditDialog
        open={isEditDialogOpen}
        recipe={selectedRecipe}
        onClose={() => {
          setIsEditDialogOpen(false)
          setSelectedRecipe(null)
        }}
        onSuccess={handleCreateSuccess}
      />

      {/* レシピ削除ダイアログ */}
      <RecipeDeleteDialog
        open={isDeleteDialogOpen}
        recipe={selectedRecipe}
        onClose={() => {
          setIsDeleteDialogOpen(false)
          setSelectedRecipe(null)
        }}
        onSuccess={handleCreateSuccess}
      />
    </Box>
  )
}

export default RecipeList
