; =============================================================================
;  Block Strike — управление одной рукой (только мышь)
;  AutoHotkey v2  (https://www.autohotkey.com/  -> Download v2)
;
;  Для тех, у кого занята/сломана левая рука: всё управление на мышке.
;  Это просто переназначение кнопок, как в настройках мыши —
;  никакого аимбота/автострельбы, прицеливаешься сам.
;
;  Кнопки (мышь с двумя боковыми кнопками):
;    Средняя кнопка (колесо)      — вкл/выкл автобег вперёд (держит W)
;    Боковая «вперёд» (XButton2)  — прыжок (Space)
;    Боковая «назад»  (XButton1)  — перезарядка (R)
;    Колесо вверх/вниз            — стрейф влево/вправо (A / D, короткий шаг)
;    Shift + колесо              — смена оружия (как обычно колесо)
;    ПКМ удерживать > 0.3 c       — присесть, пока держишь (Ctrl)
;    ПКМ короткий клик            — обычный ПКМ (прицел)
;
;  F8  — пауза скрипта (например, чтобы писать в чат)
;  F9  — выход
;
;  Если в игре другие клавиши — поменяй их в блоке НАСТРОЙКИ ниже.
; =============================================================================
#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"

; ----------------------------- НАСТРОЙКИ -------------------------------------
KEY_FORWARD := "w"
KEY_LEFT    := "a"
KEY_RIGHT   := "d"
KEY_JUMP    := "Space"
KEY_RELOAD  := "r"
KEY_CROUCH  := "LCtrl"
STRAFE_MS   := 180     ; сколько мс держать A/D на один щелчок колеса
CROUCH_HOLD := 300     ; через сколько мс удержания ПКМ включается присед
; -----------------------------------------------------------------------------

global autoRun := false

TrayTip "Block Strike: одна рука", "Скрипт запущен. F8 — пауза, F9 — выход."

; Работает только когда активно окно игры. Если не срабатывает —
; проверь заголовок окна (Window Spy в трее AHK) и поправь строку ниже.
#HotIf WinActive("Block Strike")

; --- автобег ---
MButton:: {
    global autoRun
    autoRun := !autoRun
    Send "{" KEY_FORWARD (autoRun ? " down}" : " up}")
    ToolTip autoRun ? "Автобег: ВКЛ" : "Автобег: ВЫКЛ"
    SetTimer () => ToolTip(), -800
}

; --- прыжок / перезарядка ---
XButton2::Send "{" KEY_JUMP "}"
XButton1::Send "{" KEY_RELOAD "}"

; --- стрейф колесом ---
WheelUp:: Strafe(KEY_LEFT)
WheelDown:: Strafe(KEY_RIGHT)

Strafe(key) {
    Send "{" key " down}"
    SetTimer () => Send("{" key " up}"), -STRAFE_MS
}

; --- смена оружия: Shift + колесо ---
+WheelUp::Send "{WheelUp}"
+WheelDown::Send "{WheelDown}"

; --- ПКМ: клик = прицел, удержание = присед ---
RButton:: {
    if KeyWait("RButton", "T" CROUCH_HOLD / 1000) {
        Send "{RButton}"          ; отпустил быстро — обычный клик
        return
    }
    Send "{" KEY_CROUCH " down}"  ; держит — сидим
    KeyWait "RButton"
    Send "{" KEY_CROUCH " up}"
}

#HotIf

; --- служебное (работают и на паузе) ---
#SuspendExempt
F8:: {
    global autoRun
    Suspend -1
    if A_IsSuspended && autoRun {
        autoRun := false
        Send "{" KEY_FORWARD " up}"
    }
    ToolTip A_IsSuspended ? "Скрипт на паузе" : "Скрипт работает"
    SetTimer () => ToolTip(), -800
}
F9::ExitApp
#SuspendExempt False
