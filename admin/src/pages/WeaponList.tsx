import React, { useState } from 'react'
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
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
} from '@mui/material'
import {
  Edit as EditIcon,
  Delete as DeleteIcon,
  Add as AddIcon,
  Visibility as ViewIcon,
} from '@mui/icons-material'
import { useGetWeaponsQuery } from '../services/api'
import { WeaponCreateDialog } from '../components/WeaponCreateDialog'
import { WeaponEditDialog } from '../components/WeaponEditDialog'
import { WeaponDeleteDialog } from '../components/WeaponDeleteDialog'
import Pagination from '../components/Pagination'

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
  
  const { data: weaponsData, isLoading, error, refetch } = useGetWeaponsQuery({
    page,
    limit: itemsPerPage,
  })
  
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false)
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false)
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false)
  const [selectedWeapon, setSelectedWeapon] = useState<any>(null)
  
  // APIデータまたはモックデータを使用
  const weapons = weaponsData?.data || mockWeapons
  const totalItems = weaponsData?.total || mockWeapons.length
  const totalPages = Math.ceil(totalItems / itemsPerPage)

  const handleEdit = (weapon: any) => {
    setSelectedWeapon(weapon)
    setIsEditDialogOpen(true)
  }

  const handleDelete = (weapon: any) => {
    setSelectedWeapon(weapon)
    setIsDeleteDialogOpen(true)
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
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>ID</TableCell>
                  <TableCell>名前</TableCell>
                  <TableCell>種別</TableCell>
                  <TableCell>レアリティ</TableCell>
                  <TableCell align="right">攻撃力</TableCell>
                  <TableCell align="right">価格</TableCell>
                  <TableCell align="right">必要レベル</TableCell>
                  <TableCell>合成可能</TableCell>
                  <TableCell>状態</TableCell>
                  <TableCell align="center">操作</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {weapons.map((weapon) => (
                  <TableRow key={weapon.id} hover>
                    <TableCell>{weapon.id}</TableCell>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {weapon.name}
                      </Typography>
                    </TableCell>
                    <TableCell>{weapon.weapon_type.name}</TableCell>
                    <TableCell>
                      <Chip
                        label={weapon.rarity.name}
                        size="small"
                        sx={{
                          backgroundColor: weapon.rarity.color_code,
                          color: 'white',
                        }}
                      />
                    </TableCell>
                    <TableCell align="right">{weapon.base_attack}</TableCell>
                    <TableCell align="right">{weapon.base_price}G</TableCell>
                    <TableCell align="right">Lv.{weapon.required_level}</TableCell>
                    <TableCell>
                      <Chip
                        label={weapon.is_craftable ? '可能' : '不可'}
                        size="small"
                        color={weapon.is_craftable ? 'success' : 'default'}
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={weapon.is_active ? '有効' : '無効'}
                        size="small"
                        color={weapon.is_active ? 'success' : 'error'}
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell align="center">
                      <Tooltip title="詳細表示">
                        <IconButton
                          size="small"
                          onClick={() => handleView(weapon.id)}
                        >
                          <ViewIcon />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="編集">
                        <IconButton
                          size="small"
                          onClick={() => handleEdit(weapon)}
                        >
                          <EditIcon />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="削除">
                        <IconButton
                          size="small"
                          color="error"
                          onClick={() => handleDelete(weapon)}
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
    </Box>
  )
}

export default WeaponList
