import React, { useState } from 'react'
import {
  Box,
  Typography,
  Card,
  CardContent,
  Chip,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
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
  
  // APIデータまたはモックデータを使用
  const recipes = recipesData?.data || mockRecipes
  const totalItems = recipesData?.total || mockRecipes.length
  const totalPages = Math.ceil(totalItems / itemsPerPage)

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
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>ID</TableCell>
                  <TableCell>レシピ名</TableCell>
                  <TableCell>生成武器</TableCell>
                  <TableCell>必要素材</TableCell>
                  <TableCell align="right">コスト</TableCell>
                  <TableCell align="right">成功率</TableCell>
                  <TableCell align="right">必要Lv</TableCell>
                  <TableCell>状態</TableCell>
                  <TableCell align="center">操作</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {recipes.map((recipe) => (
                  <TableRow key={recipe.id} hover>
                    <TableCell>{recipe.id}</TableCell>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {recipe.name}
                      </Typography>
                      <Typography variant="caption" color="textSecondary">
                        {recipe.description}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Box display="flex" alignItems="center" gap={1}>
                        <Typography variant="body2">
                          {recipe.weapon?.name}
                        </Typography>
                        <Chip
                          label={recipe.weapon?.rarity?.name}
                          size="small"
                          sx={{
                            backgroundColor: recipe.weapon?.rarity?.color_code,
                            color: 'white',
                          }}
                        />
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Stack spacing={0.5}>
                        {recipe.materials?.map((material: any, index: number) => (
                          <Box key={index} sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                            <Chip
                              label={material.material?.rarity?.name}
                              size="small"
                              sx={{
                                backgroundColor: material.material?.rarity?.color_code,
                                color: 'white',
                                minWidth: 50,
                                fontSize: '0.6rem',
                              }}
                            />
                            <Typography variant="caption">
                              {material.material?.name} ×{material.quantity}
                            </Typography>
                          </Box>
                        ))}
                      </Stack>
                    </TableCell>
                    <TableCell align="right">
                      <Typography variant="body2">
                        {recipe.gold_cost}G
                      </Typography>
                    </TableCell>
                    <TableCell align="right">
                      <Chip
                        label={`${Math.round((recipe.success_rate || 0) * 100)}%`}
                        size="small"
                        color={recipe.success_rate >= 0.8 ? 'success' : recipe.success_rate >= 0.5 ? 'warning' : 'error'}
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell align="right">
                      <Typography variant="body2">
                        Lv.{recipe.required_level}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={recipe.is_active ? '有効' : '無効'}
                        size="small"
                        color={recipe.is_active ? 'success' : 'error'}
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell align="center">
                      <Tooltip title="詳細表示">
                        <IconButton
                          size="small"
                          onClick={() => handleView(recipe.id)}
                        >
                          <ViewIcon />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="編集">
                        <IconButton
                          size="small"
                          onClick={() => handleEdit(recipe)}
                        >
                          <EditIcon />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="削除">
                        <IconButton
                          size="small"
                          color="error"
                          onClick={() => handleDelete(recipe)}
                        >
                          <DeleteIcon />
                        </IconButton>
                      </Tooltip>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
          
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
