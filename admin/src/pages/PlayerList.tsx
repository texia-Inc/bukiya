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
} from '@mui/material'
import {
  Edit as EditIcon,
  Block as BanIcon,
  Add as AddIcon,
  Visibility as ViewIcon,
  CheckCircle as UnbanIcon,
} from '@mui/icons-material'
import { useGetPlayersQuery } from '../services/api'
import { PlayerDetailDialog } from '../components/PlayerDetailDialog'
import { PlayerEditDialog } from '../components/PlayerEditDialog'
import { PlayerBanDialog } from '../components/PlayerBanDialog'

// モックデータ
const mockPlayers = [
  {
    id: 'player_001',
    username: 'DragonSlayer',
    email: 'dragon@example.com',
    shop_level: 15,
    experience: 12500,
    gold: 50000,
    gems: 250,
    reputation: 100,
    is_active: true,
    is_banned: false,
    last_login: '2025-06-02T10:30:00Z',
    created_at: '2025-05-01T09:00:00Z',
  },
  {
    id: 'player_002',
    username: 'MagicCrafter',
    email: 'magic@example.com',
    shop_level: 8,
    experience: 4200,
    gold: 15000,
    gems: 80,
    reputation: 50,
    is_active: true,
    is_banned: false,
    last_login: '2025-06-02T08:15:00Z',
    created_at: '2025-05-15T14:30:00Z',
  },
  {
    id: 'player_003',
    username: 'SwordMaster',
    email: 'sword@example.com',
    shop_level: 22,
    experience: 35000,
    gold: 120000,
    gems: 500,
    reputation: 200,
    is_active: true,
    is_banned: false,
    last_login: '2025-06-01T20:45:00Z',
    created_at: '2025-04-10T11:20:00Z',
  },
  {
    id: 'player_004',
    username: 'Cheater123',
    email: 'cheater@example.com',
    shop_level: 5,
    experience: 1000,
    gold: 5000,
    gems: 20,
    reputation: -50,
    is_active: false,
    is_banned: true,
    ban_reason: '不正行為により永久停止',
    last_login: '2025-05-20T16:00:00Z',
    created_at: '2025-05-20T10:00:00Z',
  },
  {
    id: 'player_005',
    username: 'NewAdventurer',
    email: 'newbie@example.com',
    shop_level: 1,
    experience: 100,
    gold: 1000,
    gems: 10,
    reputation: 10,
    is_active: true,
    is_banned: false,
    last_login: '2025-06-02T11:00:00Z',
    created_at: '2025-06-01T15:30:00Z',
  },
]

const PlayerList: React.FC = () => {
  const { data: playersData, isLoading, error, refetch } = useGetPlayersQuery({})
  
  // ダイアログの状態管理
  const [detailDialogOpen, setDetailDialogOpen] = useState(false)
  const [editDialogOpen, setEditDialogOpen] = useState(false)
  const [banDialogOpen, setBanDialogOpen] = useState(false)
  const [selectedPlayer, setSelectedPlayer] = useState<any>(null)
  
  // APIデータまたはモックデータを使用
  const players = playersData?.data || mockPlayers

  const handleView = (player: any) => {
    setSelectedPlayer(player)
    setDetailDialogOpen(true)
  }

  const handleEdit = (player: any) => {
    setSelectedPlayer(player)
    setEditDialogOpen(true)
  }

  const handleBan = (player: any) => {
    setSelectedPlayer(player)
    setBanDialogOpen(true)
  }

  const handleAdd = () => {
    console.log('Add new player')
    // TODO: プレイヤー作成ダイアログを実装
  }

  const handleDialogSuccess = () => {
    refetch() // データを再取得
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('ja-JP', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    })
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
          プレイヤー管理
        </Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={handleAdd}
        >
          新規プレイヤー追加
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
                総プレイヤー数
              </Typography>
              <Typography variant="h4">
                {players.length}
              </Typography>
            </CardContent>
          </Card>
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                アクティブプレイヤー
              </Typography>
              <Typography variant="h4">
                {players.filter(p => p.is_active && !p.is_banned).length}
              </Typography>
            </CardContent>
          </Card>
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                平均レベル
              </Typography>
              <Typography variant="h4">
                {players.length > 0 ? Math.round(players.reduce((sum, p) => sum + p.shop_level, 0) / players.length) : 0}
              </Typography>
            </CardContent>
          </Card>
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <Card>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>
                停止中プレイヤー
              </Typography>
              <Typography variant="h4" color="error">
                {players.filter(p => p.is_banned).length}
              </Typography>
            </CardContent>
          </Card>
        </Box>
      </Box>

      {/* プレイヤー一覧テーブル */}
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            プレイヤー一覧
          </Typography>
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>ユーザー名</TableCell>
                  <TableCell>メール</TableCell>
                  <TableCell align="right">レベル</TableCell>
                  <TableCell align="right">ゴールド</TableCell>
                  <TableCell align="right">ジェム</TableCell>
                  <TableCell>最終ログイン</TableCell>
                  <TableCell>状態</TableCell>
                  <TableCell align="center">操作</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {players.map((player) => (
                  <TableRow key={player.id} hover>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {player.username}
                      </Typography>
                      <Typography variant="caption" color="textSecondary">
                        ID: {player.id}
                      </Typography>
                    </TableCell>
                    <TableCell>{player.email}</TableCell>
                    <TableCell align="right">{player.shop_level}</TableCell>
                    <TableCell align="right">{player.gold.toLocaleString()}G</TableCell>
                    <TableCell align="right">{player.gems}</TableCell>
                    <TableCell>
                      <Typography variant="body2">
                        {player.last_login ? formatDate(player.last_login) : '未ログイン'}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Box display="flex" flexDirection="column" gap={0.5}>
                        <Chip
                          label={player.is_active ? 'アクティブ' : '非アクティブ'}
                          size="small"
                          color={player.is_active ? 'success' : 'default'}
                          variant="outlined"
                        />
                        {player.is_banned && (
                          <Chip
                            label="停止中"
                            size="small"
                            color="error"
                            variant="filled"
                          />
                        )}
                      </Box>
                    </TableCell>
                    <TableCell align="center">
                      <Tooltip title="詳細表示">
                        <IconButton
                          size="small"
                          onClick={() => handleView(player)}
                        >
                          <ViewIcon />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="編集">
                        <IconButton
                          size="small"
                          onClick={() => handleEdit(player)}
                        >
                          <EditIcon />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title={player.is_banned ? '停止解除' : 'アカウント停止'}>
                        <IconButton
                          size="small"
                          color={player.is_banned ? 'success' : 'error'}
                          onClick={() => handleBan(player)}
                        >
                          {player.is_banned ? <UnbanIcon /> : <BanIcon />}
                        </IconButton>
                      </Tooltip>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </CardContent>
      </Card>

      {/* ダイアログコンポーネント */}
      <PlayerDetailDialog
        open={detailDialogOpen}
        playerId={selectedPlayer?.id || null}
        onClose={() => setDetailDialogOpen(false)}
        onEdit={(player) => {
          setDetailDialogOpen(false)
          setSelectedPlayer(player)
          setEditDialogOpen(true)
        }}
        onBan={(player) => {
          setDetailDialogOpen(false)
          setSelectedPlayer(player)
          setBanDialogOpen(true)
        }}
      />

      <PlayerEditDialog
        open={editDialogOpen}
        player={selectedPlayer}
        onClose={() => setEditDialogOpen(false)}
        onSuccess={handleDialogSuccess}
      />

      <PlayerBanDialog
        open={banDialogOpen}
        player={selectedPlayer}
        onClose={() => setBanDialogOpen(false)}
        onSuccess={handleDialogSuccess}
      />
    </Box>
  )
}

export default PlayerList
