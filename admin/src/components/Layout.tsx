import React, { useState } from 'react'
import {
  AppBar,
  Box,
  CssBaseline,
  Drawer,
  IconButton,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Toolbar,
  Typography,
  useTheme,
  useMediaQuery,
} from '@mui/material'
import {
  Menu as MenuIcon,
  Dashboard as DashboardIcon,
  Build as WeaponIcon,
  Inventory as MaterialIcon,
  MenuBook as RecipeIcon,
  CalendarMonth as SeasonIcon,
  People as PlayerIcon,
  Person as AdventurerIcon,
  Pets as MonsterIcon,
  Assignment as MissionIcon,
  AutoFixHigh as EnchantmentIcon,
  Settings as SettingsIcon,
} from '@mui/icons-material'
import { useNavigate, useLocation } from 'react-router-dom'

const drawerWidth = 240

interface LayoutProps {
  children: React.ReactNode
}

const menuItems = [
  { id: 'dashboard', label: 'ダッシュボード', icon: DashboardIcon, path: '/' },
  { id: 'weapons', label: '武器管理', icon: WeaponIcon, path: '/weapons' },
  { id: 'materials', label: '素材管理', icon: MaterialIcon, path: '/materials' },
  { id: 'recipes', label: 'レシピ管理', icon: RecipeIcon, path: '/recipes' },
  { id: 'seasons', label: 'シーズン管理', icon: SeasonIcon, path: '/seasons' },
  { id: 'players', label: 'プレイヤー管理', icon: PlayerIcon, path: '/players' },
  { id: 'adventurers', label: '冒険者管理', icon: AdventurerIcon, path: '/adventurers' },
  { id: 'monsters', label: 'モンスター管理', icon: MonsterIcon, path: '/monsters' },
  { id: 'quest-areas', label: 'クエストエリア管理', icon: SettingsIcon, path: '/quest-areas' },
  { id: 'missions', label: 'ミッション管理', icon: MissionIcon, path: '/missions' },
  { id: 'enchantments', label: 'エンチャント管理', icon: EnchantmentIcon, path: '/enchantments' },
  { id: 'settings', label: '設定', icon: SettingsIcon, path: '/settings' },
]

const Layout: React.FC<LayoutProps> = ({ children }) => {
  const [mobileOpen, setMobileOpen] = useState(false)
  const theme = useTheme()
  const isMobile = useMediaQuery(theme.breakpoints.down('md'))
  const navigate = useNavigate()
  const location = useLocation()

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen)
  }

  const handleMenuClick = (path: string) => {
    navigate(path)
    if (isMobile) {
      setMobileOpen(false)
    }
  }

  const drawer = (
    <div>
      <Toolbar>
        <Typography variant="h6" noWrap component="div">
          武器屋管理画面
        </Typography>
      </Toolbar>
      <List>
        {menuItems.map((item) => {
          const Icon = item.icon
          const isSelected = location.pathname === item.path
          
          return (
            <ListItem key={item.id} disablePadding>
              <ListItemButton
                selected={isSelected}
                onClick={() => handleMenuClick(item.path)}
                sx={{
                  '&.Mui-selected': {
                    backgroundColor: theme.palette.primary.main + '20',
                    '&:hover': {
                      backgroundColor: theme.palette.primary.main + '30',
                    },
                  },
                }}
              >
                <ListItemIcon>
                  <Icon color={isSelected ? 'primary' : 'inherit'} />
                </ListItemIcon>
                <ListItemText primary={item.label} />
              </ListItemButton>
            </ListItem>
          )
        })}
      </List>
    </div>
  )

  return (
    <Box sx={{ display: 'flex' }}>
      <CssBaseline />
      <AppBar
        position="fixed"
        sx={{
          width: { md: `calc(100% - ${drawerWidth}px)` },
          ml: { md: `${drawerWidth}px` },
        }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { md: 'none' } }}
          >
            <MenuIcon />
          </IconButton>
          <Typography variant="h6" noWrap component="div">
            武器屋放置ゲーム 管理画面
          </Typography>
        </Toolbar>
      </AppBar>
      
      <Box
        component="nav"
        sx={{ width: { md: drawerWidth }, flexShrink: { md: 0 } }}
      >
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{
            keepMounted: true, // Better open performance on mobile.
          }}
          sx={{
            display: { xs: 'block', md: 'none' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
        >
          {drawer}
        </Drawer>
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: 'none', md: 'block' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
          open
        >
          {drawer}
        </Drawer>
      </Box>
      
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { md: `calc(100% - ${drawerWidth}px)` },
        }}
      >
        <Toolbar />
        {children}
      </Box>
    </Box>
  )
}

export default Layout
