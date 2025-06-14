from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
from typing import Optional
import uuid
import openai
import os
import httpx
import base64
from io import BytesIO
from PIL import Image
import aiofiles
from pathlib import Path

from app.core.database import get_db
from app.models import WeaponMaster
from app.schemas import BaseResponse
from pydantic import BaseModel

router = APIRouter()

# OpenAI API設定
openai.api_key = os.getenv("OPENAI_API_KEY")

class ImageGenerationRequest(BaseModel):
    weapon_id: int
    prompt: Optional[str] = None
    style: str = "pixel_art"
    size: str = "1024x1024"

class ImageGenerationResponse(BaseModel):
    image_url: str
    image_data: str  # base64エンコードされた画像データ
    prompt_used: str

def generate_weapon_prompt(weapon_name: str, weapon_type: str, rarity: str, style: str = "fantasy") -> str:
    """武器情報から画像生成プロンプトを作成"""
    
    # レアリティに応じた詳細な修飾子
    rarity_modifiers = {
        "コモン": {
            "appearance": "simple, basic, rough-hewn, crude",
            "materials": "iron, wood, leather",
            "effects": "weathered, battle-worn"
        },
        "アンコモン": {
            "appearance": "sturdy, well-made, functional design",
            "materials": "steel, hardwood, thick leather",
            "effects": "solid construction"
        },
        "レア": {
            "appearance": "masterwork, finely crafted, detailed engravings",
            "materials": "quality steel, exotic wood, reinforced materials",
            "effects": "superior craftsmanship"
        },
        "エピック": {
            "appearance": "legendary craftsmanship, intricate details, imposing design",
            "materials": "rare metals, ancient materials, durable components",
            "effects": "formidable presence"
        },
        "レジェンダリー": {
            "appearance": "artifact-quality, ancient design, masterful construction",
            "materials": "mythical metals, timeless materials, indestructible components",
            "effects": "imposing aura"
        }
    }
    
    # 武器タイプに応じた詳細
    weapon_details = {
        "剣": "sword with blade, crossguard, and grip",
        "杖": "staff with ornamental head and shaft",
        "弓": "bow with curved limbs and string",
        "ダガー": "dagger with sharp blade and handle",
        "ハンマー": "hammer with heavy head and long handle",
        "斧": "axe with curved blade and wooden handle"
    }
    
    # レアリティ情報を取得
    rarity_info = rarity_modifiers.get(rarity, {
        "appearance": "magical",
        "materials": "enchanted metal",
        "effects": "mystical aura"
    })
    
    weapon_detail = weapon_details.get(weapon_type, "weapon")
    
    # スタイル別のベースプロンプト
    if style == "pixel_art":
        base_prompt = f"A pixel art {weapon_detail}, {rarity_info['appearance']}, made of {rarity_info['materials']}, {rarity_info['effects']}"
        style_mod = "high resolution pixel art, 32-bit style, detailed pixels, modern pixel art, crisp edges, retro gaming aesthetic"
    elif style == "fantasy":
        base_prompt = f"A {rarity_info['appearance']} fantasy {weapon_detail}, made of {rarity_info['materials']}, {rarity_info['effects']}"
        style_mod = "fantasy art style, detailed illustration, epic fantasy aesthetic"
    elif style == "anime":
        base_prompt = f"An anime-style {weapon_detail}, {rarity_info['appearance']}, made of {rarity_info['materials']}, {rarity_info['effects']}"
        style_mod = "anime art style, clean lines, vibrant colors, cel-shaded"
    elif style == "realistic":
        base_prompt = f"A photorealistic {weapon_detail}, {rarity_info['appearance']}, made of {rarity_info['materials']}, {rarity_info['effects']}"
        style_mod = "photorealistic, detailed textures, high quality rendering"
    else:
        base_prompt = f"A {rarity_info['appearance']} {weapon_detail}, made of {rarity_info['materials']}, {rarity_info['effects']}"
        style_mod = "detailed digital artwork"
    
    # 武器のみ生成と背景透過のための強力な指示
    quality_terms = "masterpiece, high quality, professional digital art"
    isolation_terms = "transparent background, alpha channel, PNG format, isolated object"
    focus_terms = "single weapon only, one weapon, solo weapon, centered composition, clear focus, game asset style"
    weapon_only = "full weapon visible, complete weapon in frame, weapon fully contained within image borders"
    strict_avoid = "no other objects, no accessories, no decorations, no ornaments, no additional items, no background elements, no environment, no scenery, no landscape, no characters, no people, no hands, no arms, no body parts, no creatures, no animals, no monsters, no text, no letters, no words, no symbols, no writing, no logos, no brands, no numbers"
    
    prompt = f"{base_prompt}, {style_mod}, {quality_terms}, {isolation_terms}, {focus_terms}, {weapon_only}, {strict_avoid}"
    
    return prompt

@router.post("/weapons/{weapon_id}/generate", response_model=BaseResponse[ImageGenerationResponse])
async def generate_weapon_image(
    weapon_id: int,
    request: ImageGenerationRequest,
    db: Session = Depends(get_db)
):
    """
    指定された武器の画像をDALL-E APIで生成し、武器のimage_urlを自動更新
    """
    
    # OpenAI API キーの確認
    if not openai.api_key:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="OpenAI API key is not configured"
        )
    
    # 武器情報を取得
    weapon = db.query(WeaponMaster).filter(
        WeaponMaster.id == weapon_id,
        WeaponMaster.is_active == True
    ).first()
    
    if not weapon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="武器が見つかりません"
        )
    
    try:
        # プロンプトを生成または使用
        if request.prompt:
            prompt = request.prompt
        else:
            prompt = generate_weapon_prompt(
                weapon.name,
                weapon.weapon_type.name if weapon.weapon_type else "武器",
                weapon.rarity.name if weapon.rarity else "コモン",
                request.style
            )
        
        # DALL-E 3 APIで画像生成
        response = openai.images.generate(
            model="dall-e-3",
            prompt=prompt,
            size=request.size,
            quality="standard",
            n=1,
            response_format="url"
        )
        
        # 生成された画像URLを取得
        image_url = response.data[0].url
        
        # 画像をダウンロードして永続保存
        try:
            async with httpx.AsyncClient(timeout=30.0) as client:
                img_response = await client.get(image_url)
                img_response.raise_for_status()
                
                # 画像をPILで処理
                image = Image.open(BytesIO(img_response.content))
                
                # ファイル名生成（武器ID + UUID）
                file_name = f"weapon_{weapon_id}_{str(uuid.uuid4())[:8]}.png"
                
                # 保存先パス
                static_dir = Path("/app/static/images/weapons")
                static_dir.mkdir(parents=True, exist_ok=True)
                file_path = static_dir / file_name
                
                # 画像を永続保存
                image.save(file_path, format="PNG")
                
                # 相対URLを作成
                relative_url = f"/static/images/weapons/{file_name}"
                
                # 画像をbase64エンコード（レスポンス用）
                buffer = BytesIO()
                image.save(buffer, format="PNG")
                image_data = base64.b64encode(buffer.getvalue()).decode()
                
                # 武器マスターのimage_urlを永続URLに更新
                weapon.image_url = relative_url
                db.commit()
                
                # 保存したパスを返す
                saved_url = relative_url
                
        except Exception as download_error:
            # ダウンロードに失敗した場合は、一時URLを保存
            print(f"画像ダウンロード失敗: {download_error}")
            image_data = ""  # 空文字列として扱う
            
            # 一時URLを保存（フォールバック）
            weapon.image_url = image_url
            saved_url = image_url
            db.commit()
        
        return BaseResponse(
            success=True,
            data=ImageGenerationResponse(
                image_url=saved_url,
                image_data=image_data,
                prompt_used=prompt
            ),
            message="武器画像を生成し、永続保存しました",
            timestamp=datetime.utcnow(),
            request_id=str(uuid.uuid4())
        )
        
    except openai.OpenAIError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"OpenAI API error: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"画像生成に失敗しました: {str(e)}"
        )

@router.post("/generate-custom", response_model=BaseResponse[ImageGenerationResponse])
async def generate_custom_image(
    request: ImageGenerationRequest,
    db: Session = Depends(get_db)
):
    """
    カスタムプロンプトで画像を生成
    """
    
    if not openai.api_key:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="OpenAI API key is not configured"
        )
    
    if not request.prompt:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="プロンプトが必要です"
        )
    
    try:
        # DALL-E 3 APIで画像生成
        response = openai.images.generate(
            model="dall-e-3",
            prompt=request.prompt,
            size=request.size,
            quality="standard",
            n=1,
            response_format="url"
        )
        
        # 生成された画像URLを取得
        image_url = response.data[0].url
        
        # 画像をダウンロードしてbase64エンコード
        async with httpx.AsyncClient() as client:
            img_response = await client.get(image_url)
            img_response.raise_for_status()
            
            image = Image.open(BytesIO(img_response.content))
            
            buffer = BytesIO()
            image.save(buffer, format="PNG")
            image_data = base64.b64encode(buffer.getvalue()).decode()
        
        return BaseResponse(
            success=True,
            data=ImageGenerationResponse(
                image_url=image_url,
                image_data=image_data,
                prompt_used=request.prompt
            ),
            message="カスタム画像を生成しました",
            timestamp=datetime.utcnow(),
            request_id=str(uuid.uuid4())
        )
        
    except openai.OpenAIError as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"OpenAI API error: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"画像生成に失敗しました: {str(e)}"
        )