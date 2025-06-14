import React from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { Provider } from 'react-redux'
import { ThemeProvider, createTheme } from '@mui/material/styles'
import CssBaseline from '@mui/material/CssBaseline'
import { store } from './store'
import Layout from './components/Layout'
import Dashboard from './pages/Dashboard'
import WeaponList from './pages/WeaponList'
import MaterialList from './pages/MaterialList'
import RecipeList from './pages/RecipeList'
import PlayerList from './pages/PlayerList'
import AdventurerList from './pages/AdventurerList'
import MonsterList from './pages/MonsterList'
import QuestAreaList from './pages/QuestAreaList'
import MissionTemplateList from './pages/MissionTemplateList'
import EnchantmentList from './pages/EnchantmentList'
import { SeasonList } from './pages/SeasonList'

const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
    background: {
      default: '#f5f5f5',
    },
  },
  typography: {
    fontFamily: '"Roboto", "Helvetica", "Arial", sans-serif',
  },
})

function App() {
  return (
    <Provider store={store}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <Router>
          <Layout>
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/weapons" element={<WeaponList />} />
              <Route path="/materials" element={<MaterialList />} />
              <Route path="/recipes" element={<RecipeList />} />
              <Route path="/seasons" element={<SeasonList />} />
              <Route path="/players" element={<PlayerList />} />
              <Route path="/adventurers" element={<AdventurerList />} />
              <Route path="/monsters" element={<MonsterList />} />
              <Route path="/quest-areas" element={<QuestAreaList />} />
              <Route path="/missions" element={<MissionTemplateList />} />
              <Route path="/enchantments" element={<EnchantmentList />} />
            </Routes>
          </Layout>
        </Router>
      </ThemeProvider>
    </Provider>
  )
}

export default App
