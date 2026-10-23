extends Node
## Optional rewarded ads: the player chooses to watch one in exchange for a reward. Never forced,
## never during play, and capped per run or per day by whoever offers them.
##
## On Android, real AdMob ads (Poing Studios plugin, res://addons/admob): consent is asked first
## (GDPR, UMP), then one rewarded ad is kept loaded so it shows at once. Debug builds always use
## Google's test ad unit, so the account is never at risk while testing. Elsewhere (desktop,
## editor) debug builds show a fake 3-second test screen and release builds hide every ad button.

## Emitted when an ad becomes ready or stops being ready; ad buttons already on screen re-check then.
signal availability_changed

## Your rewarded ad unit from the AdMob console ("ca-app-pub-XXXX/YYYY"). Release builds show
## no ads while it is empty. The App ID goes in Project Settings > admob/general/android/app_id.
const ANDROID_REWARDED_UNIT := ""
## Google's rewarded test unit: always used in debug builds.
const TEST_REWARDED_UNIT := "ca-app-pub-3940256099942544/5224354917"
## Seconds to wait before loading again after a failed load; doubles up to the maximum.
const RETRY_DELAY := 15.0
const MAX_RETRY_DELAY := 240.0

## Placements, for analytics and for the test screen.
const REVIVE := "revive"
const DOUBLE_SILVER := "double_silver"
const EXTRA_REROLL := "extra_reroll"
const DAILY_GIFT := "daily_gift"
const NAMES := {
	REVIVE: "Revivir",
	DOUBLE_SILVER: "Duplicar la plata",
	EXTRA_REROLL: "Tirada extra",
	DAILY_GIFT: "Regalo diario",
}
## Seconds the fake ad lasts before the reward can be collected.
const TEST_AD_SECONDS := 3.0

## Set by a future "no ads" purchase: rewards are granted without showing an ad.
var ad_free := false

var _busy := false
## True on Android builds that include the AdMob plugin.
var _native := false
var _rewarded: RewardedAd
var _loading := false
var _retry_delay := RETRY_DELAY


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_native = OS.get_name() == "Android" and Engine.has_singleton("PoingGodotAdMob")
	if _native:
		_request_consent()


## True when an ad (or the no-ads pass) can give a reward right now. Ad buttons are only shown then.
func is_available() -> bool:
	if _busy:
		return false
	return ad_free or _real_available() or (OS.is_debug_build() and not _native)


## True when the player must be offered a way to change their ad consent (EEA and UK).
func privacy_options_required() -> bool:
	return _native and UserMessagingPlatform.consent_information.get_privacy_options_requirement_status() \
		== ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED


## Opens Google's form to review or change the ad consent.
func show_privacy_options() -> void:
	if _native:
		UserMessagingPlatform.show_privacy_options_form()


## Shows a rewarded ad and returns, once it closes, whether the player earned the reward.
## Use with `await`. The game stays paused while the ad is on screen.
func show_rewarded(placement: String) -> bool:
	if not is_available():
		return false
	if ad_free:
		return true
	_busy = true
	var was_paused := get_tree().paused
	get_tree().paused = true
	var rewarded: bool
	if _real_available():
		rewarded = await _show_real(placement)
	else:
		rewarded = await _show_test(placement)
	get_tree().paused = was_paused
	_busy = false
	return rewarded


# --- AdMob (Android) ----------------------------------------------------------

func _real_available() -> bool:
	return _native and _rewarded != null


func _unit_id() -> String:
	return TEST_REWARDED_UNIT if OS.is_debug_build() else ANDROID_REWARDED_UNIT


## Asks for consent where the law requires it (Google's form), then starts the SDK either way:
## without consent AdMob still serves non-personalised ads.
func _request_consent() -> void:
	UserMessagingPlatform.consent_information.update(ConsentRequestParameters.new(), _on_consent_info_updated,
		func(_error: FormError) -> void: _initialize())


func _on_consent_info_updated() -> void:
	var info := UserMessagingPlatform.consent_information
	if info.get_is_consent_form_available() and info.get_consent_status() == ConsentInformation.ConsentStatus.REQUIRED:
		UserMessagingPlatform.load_consent_form(_on_consent_form_loaded, func(_error: FormError) -> void: _initialize())
	else:
		_initialize()


func _on_consent_form_loaded(form: ConsentForm) -> void:
	form.show(func(_error: FormError) -> void: _initialize())


func _initialize() -> void:
	var listener := OnInitializationCompleteListener.new()
	listener.on_initialization_complete = func(_status: InitializationStatus) -> void: _load()
	MobileAds.initialize(listener)


func _load() -> void:
	if _loading or _rewarded != null or _unit_id().is_empty():
		return
	_loading = true
	var callback := RewardedAdLoadCallback.new()
	callback.on_ad_loaded = func(ad: RewardedAd) -> void:
		_loading = false
		_retry_delay = RETRY_DELAY
		_rewarded = ad
		availability_changed.emit()
	callback.on_ad_failed_to_load = func(error: LoadAdError) -> void:
		_loading = false
		push_warning("AdMob: rewarded ad failed to load: %s" % error.message)
		get_tree().create_timer(_retry_delay, true).timeout.connect(_load)
		_retry_delay = minf(_retry_delay * 2.0, MAX_RETRY_DELAY)
	RewardedAdLoader.new().load(_unit_id(), AdRequest.new(), callback)


## Shows the loaded ad and waits until it closes. The reward only counts if AdMob says it was earned.
func _show_real(_placement: String) -> bool:
	var ad := _rewarded
	_rewarded = null
	availability_changed.emit()
	var state := [false, false]  # [closed, rewarded]
	ad.full_screen_content_callback.on_ad_dismissed_full_screen_content = func() -> void: state[0] = true
	ad.full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(error: AdError) -> void:
		push_warning("AdMob: rewarded ad failed to show: %s" % error.message)
		state[0] = true
	var listener := OnUserEarnedRewardListener.new()
	listener.on_user_earned_reward = func(_item: RewardedItem) -> void: state[1] = true
	ad.show(listener)
	while not state[0]:
		await get_tree().process_frame
	# The reward and the close come in separately; give a late reward a few frames to arrive.
	for i in 5:
		if state[1]:
			break
		await get_tree().process_frame
	ad.destroy()
	_load()
	return state[1]


# --- Test ad, debug builds only ----------------------------------------------

## A full-screen placeholder with a countdown: "Recoger" gives the reward, "Cerrar" doesn't.
func _show_test(placement: String) -> bool:
	var layer := CanvasLayer.new()
	layer.layer = 100
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.01, 0.04, 0.95)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var title := Label.new()
	title.text = "Anuncio de prueba"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Palette.GOLD)
	box.add_child(title)
	var info := Label.new()
	info.text = "Recompensa: %s\nAquí iría un anuncio real (solo se ve en builds de depuración)." % NAMES.get(placement, placement)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 20)
	box.add_child(info)
	var countdown := Label.new()
	countdown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown.add_theme_font_size_override("font_size", 28)
	box.add_child(countdown)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 16)
	box.add_child(buttons)
	var close := Button.new()
	close.text = "Cerrar"
	close.custom_minimum_size = Vector2(200, 54)
	buttons.add_child(close)
	var collect := Button.new()
	collect.text = "Recoger"
	collect.custom_minimum_size = Vector2(200, 54)
	collect.disabled = true
	buttons.add_child(collect)
	close.grab_focus()

	var result := [false, false]  # [done, rewarded]
	close.pressed.connect(func() -> void: result[0] = true)
	collect.pressed.connect(func() -> void:
		result[1] = true
		result[0] = true)
	var left := TEST_AD_SECONDS
	while not result[0]:
		countdown.text = "%d" % ceili(left) if left > 0.0 else "¡Listo!"
		if left <= 0.0 and collect.disabled:
			collect.disabled = false
			collect.grab_focus()
		await get_tree().process_frame
		left -= get_process_delta_time()
	layer.queue_free()
	Audio.play(&"click", 0.0)
	return result[1]
