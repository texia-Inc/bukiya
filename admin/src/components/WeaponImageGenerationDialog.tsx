import React, { useState } from 'react'
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Box,
  Typography,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  TextField,
  Alert,
  CircularProgress,
  Card,
  CardMedia,
  CardContent,
} from '@mui/material'
import {
  AutoAwesome as MagicIcon,
  Download as DownloadIcon,
  Refresh as RefreshIcon,
} from '@mui/icons-material'

interface WeaponImageGenerationDialogProps {
  open: boolean
  weapon: any
  onClose: () => void
  onSuccess?: (imageData: string) => void
}

interface ImageGenerationRequest {
  weapon_id: number
  prompt?: string
  style: string
  size: string
}

interface ImageGenerationResponse {
  image_url: string
  image_data: string
  prompt_used: string
}

const WeaponImageGenerationDialog: React.FC<WeaponImageGenerationDialogProps> = ({
  open,
  weapon,
  onClose,
  onSuccess,
}) => {
  const [style, setStyle] = useState('pixel_art')
  const [size, setSize] = useState('1024x1024')
  const [customPrompt, setCustomPrompt] = useState('')
  const [useCustomPrompt, setUseCustomPrompt] = useState(false)
  const [isGenerating, setIsGenerating] = useState(false)
  const [generatedImage, setGeneratedImage] = useState<ImageGenerationResponse | null>(null)
  const [error, setError] = useState<string | null>(null)

  const handleGenerate = async () => {
    if (!weapon) return

    setIsGenerating(true)
    setError(null)
    setGeneratedImage(null)

    try {
      const requestData: ImageGenerationRequest = {
        weapon_id: weapon.id,
        style,
        size,
        ...(useCustomPrompt && customPrompt ? { prompt: customPrompt } : {}),
      }

      const response = await fetch(`http://localhost:8000/api/v1/image-generation/weapons/${weapon.id}/generate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestData),
      })

      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.detail || 'Failed to generate image')
      }

      const data = await response.json()
      if (data.success) {
        setGeneratedImage(data.data)
        onSuccess?.(data.data.image_data)
        
        // 自動でページリフレッシュして更新されたimage_urlを反映
        setTimeout(() => {
          window.location.reload()
        }, 2000)
      } else {
        throw new Error(data.message || 'Failed to generate image')
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error occurred')
    } finally {
      setIsGenerating(false)
    }
  }

  const handleDownload = () => {
    if (!generatedImage) return

    const link = document.createElement('a')
    if (generatedImage.image_data) {
      link.href = `data:image/png;base64,${generatedImage.image_data}`
    } else {
      link.href = generatedImage.image_url
    }
    link.download = `${weapon?.name || 'weapon'}_generated.png`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }

  const handleClose = () => {
    setGeneratedImage(null)
    setError(null)
    setCustomPrompt('')
    setUseCustomPrompt(false)
    onClose()
  }

  const getPreviewPrompt = () => {
    if (useCustomPrompt && customPrompt) {
      return customPrompt
    }

    if (!weapon) return ''

    const rarityModifiers: { [key: string]: any } = {
      'コモン': {
        appearance: 'simple, basic, rough-hewn, crude',
        materials: 'iron, wood, leather',
        effects: 'weathered, battle-worn'
      },
      'アンコモン': {
        appearance: 'sturdy, well-made, functional design',
        materials: 'steel, hardwood, thick leather',
        effects: 'solid construction'
      },
      'レア': {
        appearance: 'masterwork, finely crafted, detailed engravings',
        materials: 'quality steel, exotic wood, reinforced materials',
        effects: 'superior craftsmanship'
      },
      'エピック': {
        appearance: 'legendary craftsmanship, intricate details, imposing design',
        materials: 'rare metals, ancient materials, durable components',
        effects: 'formidable presence'
      },
      'レジェンダリー': {
        appearance: 'artifact-quality, ancient design, masterful construction',
        materials: 'mythical metals, timeless materials, indestructible components',
        effects: 'imposing aura'
      }
    }

    const weaponDetails: { [key: string]: string } = {
      '剣': 'sword with blade, crossguard, and grip',
      '杖': 'staff with ornamental head and shaft',
      '弓': 'bow with curved limbs and string',
      'ダガー': 'dagger with sharp blade and handle',
      'ハンマー': 'hammer with heavy head and long handle',
      '斧': 'axe with curved blade and wooden handle'
    }

    const rarityInfo = rarityModifiers[weapon.rarity?.name] || {
      appearance: 'magical',
      materials: 'enchanted metal',
      effects: 'mystical aura'
    }
    const weaponDetail = weaponDetails[weapon.weapon_type?.name] || 'weapon'
    
    let basePrompt = ''
    let styleMod = ''

    if (style === 'pixel_art') {
      basePrompt = `A pixel art ${weaponDetail}, ${rarityInfo.appearance}, made of ${rarityInfo.materials}, ${rarityInfo.effects}`
      styleMod = 'high resolution pixel art, 32-bit style, detailed pixels, modern pixel art, crisp edges, retro gaming aesthetic'
    } else if (style === 'fantasy') {
      basePrompt = `A ${rarityInfo.appearance} fantasy ${weaponDetail}, made of ${rarityInfo.materials}, ${rarityInfo.effects}`
      styleMod = 'fantasy art style, detailed illustration, epic fantasy aesthetic'
    } else if (style === 'anime') {
      basePrompt = `An anime-style ${weaponDetail}, ${rarityInfo.appearance}, made of ${rarityInfo.materials}, ${rarityInfo.effects}`
      styleMod = 'anime art style, clean lines, vibrant colors, cel-shaded'
    } else if (style === 'realistic') {
      basePrompt = `A photorealistic ${weaponDetail}, ${rarityInfo.appearance}, made of ${rarityInfo.materials}, ${rarityInfo.effects}`
      styleMod = 'photorealistic, detailed textures, high quality rendering'
    } else {
      basePrompt = `A ${rarityInfo.appearance} ${weaponDetail}, made of ${rarityInfo.materials}, ${rarityInfo.effects}`
      styleMod = 'detailed digital artwork'
    }

    const qualityTerms = 'masterpiece, high quality, professional digital art'
    const isolationTerms = 'transparent background, alpha channel, PNG format, isolated object'
    const focusTerms = 'single weapon only, one weapon, solo weapon, centered composition, clear focus, game asset style'
    const weaponOnly = 'full weapon visible, complete weapon in frame, weapon fully contained within image borders'
    const strictAvoid = 'no other objects, no accessories, no decorations, no ornaments, no additional items, no background elements, no environment, no scenery, no landscape, no characters, no people, no hands, no arms, no body parts, no creatures, no animals, no monsters, no text, no letters, no words, no symbols, no writing, no logos, no brands, no numbers'

    return `${basePrompt}, ${styleMod}, ${qualityTerms}, ${isolationTerms}, ${focusTerms}, ${weaponOnly}, ${strictAvoid}`
  }

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="md" fullWidth>
      <DialogTitle>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <MagicIcon />
          武器画像生成 - {weapon?.name}
        </Box>
      </DialogTitle>
      
      <DialogContent>
        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
          {/* エラー表示 */}
          {error && (
            <Alert severity="error">
              {error}
            </Alert>
          )}

          {/* 武器情報 */}
          <Card variant="outlined">
            <CardContent>
              <Typography variant="h6" gutterBottom>
                武器情報
              </Typography>
              <Box sx={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))', gap: 1 }}>
                <Typography variant="body2">
                  <strong>名前:</strong> {weapon?.name}
                </Typography>
                <Typography variant="body2">
                  <strong>種別:</strong> {weapon?.weapon_type?.name}
                </Typography>
                <Typography variant="body2">
                  <strong>レアリティ:</strong> {weapon?.rarity?.name}
                </Typography>
                <Typography variant="body2">
                  <strong>攻撃力:</strong> {weapon?.base_attack}
                </Typography>
              </Box>
            </CardContent>
          </Card>

          {/* 生成設定 */}
          <Box sx={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 2 }}>
            <FormControl fullWidth>
              <InputLabel>アートスタイル</InputLabel>
              <Select
                value={style}
                onChange={(e) => setStyle(e.target.value)}
                label="アートスタイル"
              >
                <MenuItem value="pixel_art">ピクセルアート（推奨）</MenuItem>
                <MenuItem value="fantasy">ファンタジー</MenuItem>
                <MenuItem value="anime">アニメ</MenuItem>
                <MenuItem value="realistic">リアル</MenuItem>
              </Select>
            </FormControl>

            <FormControl fullWidth>
              <InputLabel>画像サイズ</InputLabel>
              <Select
                value={size}
                onChange={(e) => setSize(e.target.value)}
                label="画像サイズ"
              >
                <MenuItem value="1024x1024">1024x1024 (正方形)</MenuItem>
                <MenuItem value="1024x1792">1024x1792 (縦長)</MenuItem>
                <MenuItem value="1792x1024">1792x1024 (横長)</MenuItem>
              </Select>
            </FormControl>
          </Box>

          {/* カスタムプロンプト */}
          <Box>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
              <Typography variant="h6">
                プロンプト設定
              </Typography>
              <Button
                size="small"
                variant={useCustomPrompt ? "contained" : "outlined"}
                onClick={() => setUseCustomPrompt(!useCustomPrompt)}
              >
                {useCustomPrompt ? "自動生成に戻す" : "カスタムプロンプト"}
              </Button>
            </Box>
            
            {useCustomPrompt ? (
              <TextField
                fullWidth
                multiline
                rows={3}
                label="カスタムプロンプト"
                value={customPrompt}
                onChange={(e) => setCustomPrompt(e.target.value)}
                placeholder="武器の詳細な説明を英語で入力してください..."
              />
            ) : (
              <Card variant="outlined" sx={{ backgroundColor: 'grey.50' }}>
                <CardContent>
                  <Typography variant="body2" color="text.secondary">
                    自動生成されるプロンプト:
                  </Typography>
                  <Typography variant="body2" sx={{ fontFamily: 'monospace', mt: 1 }}>
                    {getPreviewPrompt()}
                  </Typography>
                </CardContent>
              </Card>
            )}
          </Box>

          {/* 生成された画像 */}
          {generatedImage && (
            <Card variant="outlined">
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  生成された画像
                </Typography>
                <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2 }}>
                  <CardMedia
                    component="img"
                    sx={{ 
                      maxWidth: '100%', 
                      maxHeight: 400, 
                      objectFit: 'contain',
                      border: '1px solid',
                      borderColor: 'grey.300',
                      borderRadius: 1,
                    }}
                    image={generatedImage.image_data ? `data:image/png;base64,${generatedImage.image_data}` : generatedImage.image_url}
                    alt="Generated weapon"
                  />
                  <Box sx={{ display: 'flex', gap: 1 }}>
                    <Button
                      variant="outlined"
                      startIcon={<DownloadIcon />}
                      onClick={handleDownload}
                    >
                      ダウンロード
                    </Button>
                    <Button
                      variant="outlined"
                      startIcon={<RefreshIcon />}
                      onClick={handleGenerate}
                      disabled={isGenerating}
                    >
                      再生成
                    </Button>
                  </Box>
                </Box>
                <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                  <strong>使用されたプロンプト:</strong> {generatedImage.prompt_used}
                </Typography>
              </CardContent>
            </Card>
          )}
        </Box>
      </DialogContent>

      <DialogActions>
        <Button onClick={handleClose}>
          {generatedImage ? '完了' : 'キャンセル'}
        </Button>
        <Button
          variant="contained"
          onClick={handleGenerate}
          disabled={isGenerating || (useCustomPrompt && !customPrompt.trim())}
          startIcon={isGenerating ? <CircularProgress size={20} /> : <MagicIcon />}
        >
          {isGenerating ? '生成中...' : generatedImage ? '再生成' : '画像生成'}
        </Button>
      </DialogActions>
    </Dialog>
  )
}

export default WeaponImageGenerationDialog