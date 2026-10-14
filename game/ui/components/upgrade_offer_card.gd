class_name UpgradeOfferCard
extends Button

@onready var rarity_label: Label = %RarityLabel
@onready var tower_icon: TextureRect = %TowerIcon
@onready var title_label: RichTextLabel = %TitleLabel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var tier_background: TextureRect = %TierBackground
@onready var card_frame: NinePatchRect = %CardFrame

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func configure_visuals(icon_texture: Texture2D, rarity: int, icon_catalog: Resource) -> void:
	tower_icon.texture = icon_texture
	tower_icon.visible = icon_texture != null
	tier_background.texture = icon_catalog.call("get_card_tier_background", rarity) as Texture2D
	card_frame.texture = icon_catalog.get("upgrade_card_frame") as Texture2D

func _on_mouse_entered() -> void:
	card_frame.modulate = Color(1.16, 1.14, 1.08, 1.0)

func _on_mouse_exited() -> void:
	card_frame.modulate = Color.WHITE
