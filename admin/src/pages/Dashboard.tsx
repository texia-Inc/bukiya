import React from 'react'
import {
  Box,
  Card,
  CardContent,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  CircularProgress,
  Alert,
} from '@mui/material'
import {
  People as PeopleIcon,
  Build as WeaponIcon,
  Inventory as MaterialIcon,
  MenuBook as RecipeIcon,
} from '@mui/icons-material'
import { useGetWeaponsQuery } from '../services/api'

// モックデータ（後でAPIから取得）
const mockStats = {
  total_players: 1250,
  total_weapons: 24,
  total_materials: 10,
  total_recipes: 15,
  active_players_today: 89,
  total_gold_in_circulation: 2500000,
  most_popular_weapon: '鋼鉄の剣',
  recent_registrations: 12,
}

const mockRecentActivity = [
  { id: 1, action: 'プレイヤー登録', user: 'player123', time: '2分前' },
  { id: 2, action: '武器合成', user: 'warrior456', time: '5分前' },
  { id: 3, action: '素材売却', user: 'crafter789', time: '8分前' },
  { id: 4, action: 'エンチャント', user: 'mage101', time: '12分前' },
  { id: 5, action: '武器売却', user: 'trader202', time: '15分前' },
]

const mockPopularWeapons = [
  { name: '鋼鉄の剣', count: 156, percentage: 25.2 },
  { name: '炎の杖', count: 134, percentage: 21.7 },
  { name: '氷の弓', count: 98, percentage: 15.9 },
  { name: '雷の斧', count: 87, percentage: 14.1 },
  { name: '風の短剣', count: 72, percentage: 11.6 },
]

interface StatCardProps {
  title: string
  value: string | number
  icon: React.ReactNode
  color: string
}

const StatCard: React.FC<StatCardProps> = ({ title, value, icon, color }) => (
  <Card sx={{ height: '100%' }}>
    <CardContent>
      <Box display="flex" alignItems="center" justifyContent="space-between">
        <Box>
          <Typography color="textSecondary" gutterBottom variant="body2">
            {title}
          </Typography>
          <Typography variant="h4" component="div">
            {typeof value === 'number' ? value.toLocaleString() : value}
          </Typography>
        </Box>
        <Box sx={{ color, fontSize: 40 }}>
          {icon}
        </Box>
      </Box>
    </CardContent>
  </Card>
)

const Dashboard: React.FC = () => {
  const { data: weaponsData, isLoading: weaponsLoading, error: weaponsError } = useGetWeaponsQuery({})

  // APIデータまたはモックデータを使用
  const stats = mockStats // 統計APIが実装されていないため、モックデータを使用
  const weapons = weaponsData?.data || []

  if (weaponsLoading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      {weaponsError && (
        <Alert severity="info" sx={{ mb: 2 }}>
          一部のAPIに接続できません。利用可能なデータとモックデータを表示しています。
        </Alert>
      )}
      
      <Typography variant="h4" component="h1" gutterBottom>
        ダッシュボード
      </Typography>
      
      {/* 統計カード */}
      <Box 
        display="flex" 
        flexWrap="wrap" 
        gap={3} 
        sx={{ mb: 4 }}
      >
        <Box flex="1 1 250px" minWidth="250px">
          <StatCard
            title="総プレイヤー数"
            value={stats.total_players}
            icon={<PeopleIcon />}
            color="#1976d2"
          />
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <StatCard
            title="武器種類数"
            value={stats.total_weapons}
            icon={<WeaponIcon />}
            color="#2e7d32"
          />
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <StatCard
            title="素材種類数"
            value={stats.total_materials}
            icon={<MaterialIcon />}
            color="#ed6c02"
          />
        </Box>
        <Box flex="1 1 250px" minWidth="250px">
          <StatCard
            title="レシピ数"
            value={stats.total_recipes}
            icon={<RecipeIcon />}
            color="#d32f2f"
          />
        </Box>
      </Box>

      <Box display="flex" flexWrap="wrap" gap={3}>
        {/* 今日のアクティブプレイヤー */}
        <Box flex="1 1 300px" minWidth="300px">
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                今日のアクティブプレイヤー
              </Typography>
              <Typography variant="h3" color="primary">
                {mockStats.active_players_today}
              </Typography>
              <Typography color="textSecondary">
                新規登録: {mockStats.recent_registrations}人
              </Typography>
            </CardContent>
          </Card>
        </Box>

        {/* 流通ゴールド */}
        <Box flex="1 1 300px" minWidth="300px">
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                流通ゴールド総額
              </Typography>
              <Typography variant="h3" color="secondary">
                {mockStats.total_gold_in_circulation.toLocaleString()}G
              </Typography>
              <Typography color="textSecondary">
                人気武器: {mockStats.most_popular_weapon}
              </Typography>
            </CardContent>
          </Card>
        </Box>

        {/* システムステータス */}
        <Box flex="1 1 300px" minWidth="300px">
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                システムステータス
              </Typography>
              <Box sx={{ mt: 2 }}>
                <Typography variant="body2" color="success.main">
                  ● API: 正常
                </Typography>
                <Typography variant="body2" color="success.main">
                  ● データベース: 正常
                </Typography>
                <Typography variant="body2" color="success.main">
                  ● Redis: 正常
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Box>
      </Box>

      <Box display="flex" flexWrap="wrap" gap={3} sx={{ mt: 3 }}>
        {/* 最近のアクティビティ */}
        <Box flex="1 1 400px" minWidth="400px">
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                最近のアクティビティ
              </Typography>
              <TableContainer>
                <Table size="small">
                  <TableHead>
                    <TableRow>
                      <TableCell>アクション</TableCell>
                      <TableCell>ユーザー</TableCell>
                      <TableCell>時刻</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {mockRecentActivity.map((activity) => (
                      <TableRow key={activity.id}>
                        <TableCell>{activity.action}</TableCell>
                        <TableCell>{activity.user}</TableCell>
                        <TableCell>{activity.time}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </CardContent>
          </Card>
        </Box>

        {/* 人気武器ランキング */}
        <Box flex="1 1 400px" minWidth="400px">
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                人気武器ランキング
              </Typography>
              <TableContainer>
                <Table size="small">
                  <TableHead>
                    <TableRow>
                      <TableCell>武器名</TableCell>
                      <TableCell align="right">所持数</TableCell>
                      <TableCell align="right">割合</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {mockPopularWeapons.map((weapon, index) => (
                      <TableRow key={weapon.name}>
                        <TableCell>
                          <Box display="flex" alignItems="center">
                            <Typography variant="body2" sx={{ mr: 1 }}>
                              {index + 1}.
                            </Typography>
                            {weapon.name}
                          </Box>
                        </TableCell>
                        <TableCell align="right">{weapon.count}</TableCell>
                        <TableCell align="right">{weapon.percentage}%</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            </CardContent>
          </Card>
        </Box>
      </Box>
    </Box>
  )
}

export default Dashboard
