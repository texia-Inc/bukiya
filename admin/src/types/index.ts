// 基本型定義
export interface BaseResponse<T> {
  success: boolean
  data?: T
  message: string
  timestamp: string
  request_id: string
}

export interface PaginatedResponse<T> extends BaseResponse<T[]> {
  pagination: {
    page: number
    limit: number
    total: number
    pages: number
  }
}

// 武器関連型
export interface WeaponType {
  id: string
  name: string
  description?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface RarityLevel {
  id: number
  name: string
  description?: string
  color_code?: string
  multiplier: number
  drop_rate: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface WeaponMaster {
  id: number
  name: string
  description?: string
  weapon_type_id: string
  rarity_id: number
  base_attack: number
  base_price: number
  required_level: number
  image_url?: string
  is_craftable: boolean
  is_active: boolean
  created_at: string
  updated_at: string
  weapon_type: WeaponType
  rarity: RarityLevel
  calculated_attack: number
  calculated_price: number
}

export interface WeaponMasterCreate {
  name: string
  description?: string
  weapon_type_id: string
  rarity_id: number
  base_attack: number
  base_price: number
  required_level: number
  image_url?: string
  is_craftable: boolean
}

export interface WeaponMasterUpdate extends Partial<WeaponMasterCreate> {
  is_active?: boolean
}

// 素材関連型
export interface MaterialMaster {
  id: number
  name: string
  description?: string
  rarity_id: number
  base_price: number
  max_stack: number
  image_url?: string
  is_active: boolean
  created_at: string
  updated_at: string
  rarity: RarityLevel
  calculated_price: number
}

export interface MaterialMasterCreate {
  name: string
  description?: string
  rarity_id: number
  base_price: number
  max_stack: number
  image_url?: string
}

export interface MaterialMasterUpdate extends Partial<MaterialMasterCreate> {
  is_active?: boolean
}

// 合成レシピ関連型
export interface RecipeMaterial {
  recipe_id: number
  material_id: number
  quantity: number
  material: MaterialMaster
}

export interface CraftingRecipe {
  id: number
  weapon_id: number
  name: string
  description?: string
  gold_cost: number
  success_rate: number
  required_level: number
  is_active: boolean
  created_at: string
  updated_at: string
  weapon: WeaponMaster
  materials: RecipeMaterial[]
}

export interface CraftingRecipeCreate {
  weapon_id: number
  name: string
  description?: string
  gold_cost: number
  success_rate: number
  required_level: number
  materials: {
    material_id: number
    quantity: number
  }[]
}

export interface CraftingRecipeUpdate extends Partial<CraftingRecipeCreate> {
  is_active?: boolean
}

// プレイヤー関連型
export interface Player {
  id: string
  username: string
  email: string
  shop_level: number
  experience: number
  gold: number
  gems: number
  is_active: boolean
  is_banned: boolean
  ban_reason?: string
  last_login?: string
  created_at: string
  updated_at: string
}

export interface PlayerWeapon {
  id: string
  player_id: string
  weapon_master_id: number
  attack: number
  enchant_level: number
  custom_name?: string
  is_equipped: boolean
  created_at: string
  updated_at: string
  weapon_master: WeaponMaster
  display_name: string
  total_attack: number
}

export interface PlayerMaterial {
  player_id: string
  material_id: number
  quantity: number
  created_at: string
  updated_at: string
  material: MaterialMaster
}

// API パラメータ型
export interface WeaponListParams {
  page?: number
  limit?: number
  weapon_type_id?: string
  rarity_id?: number
  min_level?: number
  max_level?: number
}

export interface MaterialListParams {
  page?: number
  limit?: number
  rarity_id?: number
  min_price?: number
  max_price?: number
}

export interface RecipeListParams {
  page?: number
  limit?: number
  weapon_type_id?: string
  rarity_id?: number
  max_level?: number
}

export interface PlayerListParams {
  page?: number
  limit?: number
  min_level?: number
  max_level?: number
  is_banned?: boolean
}

// UI関連型
export interface TableColumn {
  field: string
  headerName: string
  width?: number
  sortable?: boolean
  filterable?: boolean
  renderCell?: (params: any) => React.ReactNode
}

export interface FilterOption {
  value: string | number
  label: string
}

export interface DashboardStats {
  total_players: number
  total_weapons: number
  total_materials: number
  total_recipes: number
  active_players_today: number
  total_gold_in_circulation: number
  most_popular_weapon: string
  recent_registrations: number
}

// フォーム型
export interface WeaponFormData {
  name: string
  description: string
  weapon_type_id: string
  rarity_id: number
  base_attack: number
  base_price: number
  required_level: number
  image_url: string
  is_craftable: boolean
  is_active: boolean
}

export interface MaterialFormData {
  name: string
  description: string
  rarity_id: number
  base_price: number
  max_stack: number
  image_url: string
  is_active: boolean
}

export interface RecipeFormData {
  weapon_id: number
  name: string
  description: string
  gold_cost: number
  success_rate: number
  required_level: number
  materials: {
    material_id: number
    quantity: number
  }[]
  is_active: boolean
}

// エラー型
export interface ApiError {
  status: number
  data: {
    success: false
    error: {
      code: string
      message: string
      details?: any
    }
    timestamp: string
    request_id: string
  }
}

// 認証関連型
export interface AuthUser {
  id: string
  username: string
  email: string
  role: 'admin' | 'super_admin' | 'viewer'
}

export interface LoginRequest {
  email: string
  password: string
}

export interface LoginResponse {
  access_token: string
  token_type: string
  user: AuthUser
}

// ナビゲーション型
export interface NavItem {
  id: string
  label: string
  icon: React.ComponentType
  path: string
  children?: NavItem[]
}

// テーマ型
export interface ThemeConfig {
  mode: 'light' | 'dark'
  primaryColor: string
  secondaryColor: string
}

// 冒険者関連型
export interface AdventurerMaster {
  id: number
  name: string
  profession: string
  level: number
  personality: string
  trust_level: number
  budget_min: number
  budget_max: number
  preferred_weapon_type: string
  min_attack_requirement: number
  urgency_tendency: number
  spawn_weight: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface AdventurerMasterCreate {
  name: string
  profession: string
  level: number
  personality: string
  trust_level: number
  budget_min: number
  budget_max: number
  preferred_weapon_type: string
  min_attack_requirement: number
  urgency_tendency: number
  spawn_weight: number
}

export interface AdventurerMasterUpdate extends Partial<AdventurerMasterCreate> {
  is_active?: boolean
}

export interface AdventurerListParams {
  page?: number
  limit?: number
  search?: string
  profession?: string
  is_active?: boolean
}

// モンスター関連型
export interface MonsterMaster {
  id: number
  name: string
  monster_type: string
  level: number
  hp: number
  attack: number
  defense: number
  element: string | null
  weakness: string | null
  resistance: string | null
  spawn_areas: string
  spawn_weight: number
  min_required_weapon_level: number
  base_gold_reward: number
  experience_reward: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface MonsterMasterCreate {
  name: string
  monster_type: string
  level: number
  hp: number
  attack: number
  defense: number
  element?: string | null
  weakness?: string | null
  resistance?: string | null
  spawn_areas: string
  spawn_weight: number
  min_required_weapon_level: number
  base_gold_reward: number
  experience_reward: number
}

export interface MonsterMasterUpdate extends Partial<MonsterMasterCreate> {
  is_active?: boolean
}

export interface MonsterListParams {
  page?: number
  limit?: number
  search?: string
  monster_type?: string
  is_active?: boolean
}

// クエストエリア関連型
export interface QuestAreaMaster {
  id: number
  name: string
  area_type: string
  difficulty: number
  required_level: number
  duration_minutes: number
  image_url: string | null
  background_color: string
  description: string | null
  unlock_condition: string | null
  is_active: boolean
  display_order: number
  created_at: string
  updated_at: string
}

export interface QuestAreaMasterCreate {
  name: string
  area_type: string
  difficulty: number
  required_level: number
  duration_minutes: number
  image_url?: string | null
  background_color: string
  description?: string | null
  unlock_condition?: string | null
  display_order: number
}

export interface QuestAreaMasterUpdate extends Partial<QuestAreaMasterCreate> {
  is_active?: boolean
}

export interface QuestAreaListParams {
  page?: number
  limit?: number
  search?: string
  is_active?: boolean
}

// ミッションテンプレート関連型
export interface MissionTemplate {
  id: number
  name: string
  description: string
  mission_type: 'daily' | 'weekly' | 'achievement'
  target_type: string
  target_count: number
  target_conditions: any
  reward_gold: number
  reward_exp: number
  reward_items: any
  is_active: boolean
  reset_schedule: string | null
  required_level: number
  display_order: number
  created_at: string
  updated_at: string
}

export interface MissionTemplateCreate {
  name: string
  description: string
  mission_type: 'daily' | 'weekly' | 'achievement'
  target_type: string
  target_count: number
  target_conditions?: any
  reward_gold: number
  reward_exp: number
  reward_items?: any
  reset_schedule?: string | null
  required_level: number
  display_order: number
}

export interface MissionTemplateUpdate extends Partial<MissionTemplateCreate> {
  is_active?: boolean
}

export interface MissionTemplateListParams {
  page?: number
  limit?: number
  search?: string
  mission_type?: 'daily' | 'weekly' | 'achievement'
  is_active?: boolean
}
