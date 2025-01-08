        AREA    |.text|, CODE, READONLY

SYSCTL_PERIPH_GPIOF EQU     0x400FE108

GPIO_PORTF_BASE     EQU     0x40025000
GPIO_PORTE_BASE     EQU     0x40024000
GPIO_PORTD_BASE     EQU     0x40007000

GPIO_O_DIR          EQU     0x400
GPIO_O_DR2R         EQU     0x500
GPIO_O_DEN          EQU     0x51C
GPIO_PUR            EQU     0x510

; LED
PORT45              EQU     0x30
PORT5               EQU     0x20
PORT4               EQU     0x10

; Switches
PORT67              EQU     0xC0
PORT7               EQU     0x80
PORT6               EQU     0x40

; Bumpers
PORT01              EQU     0x03
PORT0               EQU     0x01
PORT1               EQU     0x02

NOL2D               EQU     0x00
LED1                EQU     0x10


DUREE            EQU     0x03FFFFF
DUREE_90         EQU     0x800000
DUREE_AVANCE_COURTE EQU     0x00440000 ; Durée pour avancer légèrement

DUREE_ONE               EQU     0x03FFFFF
DUREE_90_ONE          EQU     0x800000
DUREE_AVANCE_COURTE_ONE EQU     0x00440000 ; Durée pour avancer légèrement

DUREE_TWO             EQU     0x0FFFFF
DUREE_90_TWO          EQU     0x400000
DUREE_AVANCE_COURTE_TWO EQU     0x00240000 ; Durée pour avancer légèrement
	
DUREE_TRHEE              EQU     0x03FFFFF
DUREE_90_TRHEE            EQU     0x100000
DUREE_AVANCE_COURTE_TRHEE  EQU     0x0030000 ; Durée pour avancer légèrement

; Constantes
INCREMENT_CYCLE     EQU     0x00000FFF    ; Incrément de 10 secondes (valeur à ajuster)
BASE_DURATION       EQU     0x00FFFFF    ; Durée initiale du cycle (valeur à ajuster)

SPEED_UN			EQU		0x123
SPEED_TWO			EQU		0x53
SPEED_TRHEE			EQU		0x23

        AREA    |.data|, DATA, READWRITE

SWITCH_COUNT        DCD     0x0             ; Compteur pour le switch
CURRENT_DURATION    DCD     BASE_DURATION   ; Durée initiale configurée
SWITCH_COUNT_TWO    DCD     0x0             ; Compteur pour le switch


        AREA    |.text|, CODE, READONLY

        ENTRY
        EXPORT  __main
        IMPORT  MOTEUR_INIT
        IMPORT  MOTEUR_DROIT_ON
        IMPORT  MOTEUR_DROIT_OFF
        IMPORT  MOTEUR_DROIT_AVANT
        IMPORT  MOTEUR_DROIT_ARRIERE
        IMPORT  MOTEUR_GAUCHE_ON
        IMPORT  MOTEUR_GAUCHE_OFF
        IMPORT  MOTEUR_GAUCHE_AVANT
        IMPORT  MOTEUR_GAUCHE_ARRIERE

__main
        ; Initialisation de la mémoire
        LDR     R0, =SWITCH_COUNT
        MOV     R1, #0
        STR     R1, [R0] ; Initialisation du compteur de Switch
		
		NOP
		NOP
		NOP
		
        LDR     R0, =CURRENT_DURATION
        LDR     R1, =BASE_DURATION
        STR     R1, [R0]               ; Initialisation de la durée à BASE_DURATION
		
		NOP
		NOP
		NOP
		
		LDR     R0, =SWITCH_COUNT_TWO
        MOV     R1, #0
        STR     R1, [R0]
		
		NOP
		NOP
		NOP
		
		
		NOP
		NOP
		NOP
           ; Activer GPIOF avec délai pour stabilisation
		LDR     R6, =SYSCTL_PERIPH_GPIOF
		MOV     R0, #0x00000038
		STR     R0, [R6]

    ; Attente après activation
		MOV     R0, #0xFFFF
delay_init
		SUBS    R0, R0, #1
		BNE     delay_init

    ; Configuration des LED (Port F)
		LDR     R6, =GPIO_PORTF_BASE + GPIO_O_DIR
		LDR     R0, =PORT45
		STR     R0, [R6]
        ; Configuration des LED (Port F)
        LDR     R6, =GPIO_PORTF_BASE + GPIO_O_DIR
        LDR     R0, =PORT45
        STR     R0, [R6]
		NOP
		NOP
		NOP

        LDR     R6, =GPIO_PORTF_BASE + GPIO_O_DEN
        LDR     R0, =PORT45
        STR     R0, [R6]
		NOP
		NOP
		NOP

        LDR     R6, =GPIO_PORTF_BASE + GPIO_O_DR2R
        LDR     R0, =PORT45
        STR     R0, [R6]
		NOP
		NOP
		NOP
        ; Initialisation des bumpers (Port E)
        LDR     R7, =GPIO_PORTE_BASE + GPIO_O_DEN
        LDR     R0, =PORT01
        STR     R0, [R7]
		NOP
		NOP
		NOP

        ; Pull-up resistors pour les bumpers
        LDR     R7, =GPIO_PORTE_BASE + GPIO_PUR
        LDR     R0, =PORT01
        STR     R0, [R7]
		NOP
		NOP
		NOP

        ; Digital - Port D
        LDR     R7, =GPIO_PORTD_BASE + GPIO_O_DEN
        LDR     R0, =PORT67
        STR     R0, [R7]
		NOP
		NOP
		NOP

        ; Pull-up resistors pour les switches
        LDR     R7, =GPIO_PORTD_BASE + GPIO_PUR
        LDR     R0, =PORT67
        STR     R0, [R7]
		NOP
		NOP
		NOP
		
		LDR     R12, =SPEED_UN
        ; Initialisation des moteurs
        BL      MOTEUR_INIT
		NOP
		NOP
		NOP
        BL      MOTEUR_DROIT_ON
        BL      MOTEUR_GAUCHE_ON
		NOP
		NOP
		NOP

        ; Initialisation de l'état (0 = gauche, 1 = droite)
        MOV     R8, #0

loop
        ldr r12, = GPIO_PORTD_BASE + (PORT6 << 2)
        ldr r11, [r12]        ; Lecture du switch
        cmp r11, #0x40               ; Bumper droit activé ?
        bne increment_duration   ; Si oui, incrémenter la durée
		
		ldr r12, = GPIO_PORTD_BASE + (PORT7 << 2)
        ldr r11, [r12]        ; Lecture du switch
        cmp r11, #0x80               ; Bumper droit activé ?
        bne update_speed
		
		
        ; Lire la durée restante
        LDR     R0, =CURRENT_DURATION
        LDR     R1, [R0]
        CMP     R1, #0                ; Durée expirée ?
        BEQ     stop_robot            ; Si oui, arrêter le robot

        ; Réduire la durée actuelle
        SUBS    R1, R1, #0
        STR     R1, [R0]

        ldr r7, = GPIO_PORTE_BASE + (PORT0 << 2)
        ldr r5, [r7]                ; État du bumper droit
        ldr r9, = GPIO_PORTE_BASE + (PORT1 << 2)
        ldr r10, [r9]               ; État du bumper gauche
        ; Vérifier les états et ajuster les moteurs/LED
        cmp r5, #0x01               ; Bumper droit activé ?
        bne handle_bumper
        cmp r10, #0x02              ; Bumper gauche activé ?
        bne handle_bumper

        ; Sinon, avancer tout droit
        MOV     R3, #PORT45
        LDR     R6, =GPIO_PORTF_BASE + GPIO_O_DIR
        STR     R3, [R6]             ; Allume les LEDs
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_AVANT

        B       loop
update_speed
        ; Incrémentation du compteur SWITCH_COUNT_TWO
        LDR     R0, =SWITCH_COUNT_TWO
		NOP
		NOP
		NOP
        LDR     R1, [R0]
        ADD     R1, R1, #1
        STR     R1, [R0]
		
        ; Vérifier la valeur du compteur et définir la vitesse
        CMP     R1, #0                                ; Si le compteur vaut 0
        BEQ     set_speed_one
        CMP     R1, #1                                ; Si le compteur vaut 1
        BEQ     set_speed_two
        CMP     R1, #2                                ; Si le compteur vaut 2
        BEQ     set_speed_three

        ; Réinitialiser le compteur à 0 si la valeur dépasse 2
        MOV     R1, #0
        STR     R1, [R0]
        B       set_speed_one                         ; Revenir à la vitesse 1

set_speed_one
		NOP
		NOP
		NOP
        LDR     R12, =SPEED_UN                        ; Charger la vitesse 1
        B       apply_speed

set_speed_two
        LDR     R12, =SPEED_TWO                       ; Charger la vitesse 2
        B       apply_speed

set_speed_three
        LDR     R12, =SPEED_TRHEE 
		NOP
		NOP
		NOP		; Charger la vitesse 3

apply_speed
        ; Appeler les fonctions pour configurer les moteurs
        BL      MOTEUR_INIT
		NOP
		NOP
		NOP
        BL      MOTEUR_DROIT_ON
        BL      MOTEUR_GAUCHE_ON
        B       loop  

increment_duration
        ; Ajouter INCREMENT_CYCLE à la durée actuelle
        LDR     R2, =INCREMENT_CYCLE
        LDR     R0, =CURRENT_DURATION
        LDR     R1, [R0]
        ADD     R1, R1, R2
        STR     R1, [R0]
        B       loop

stop_robot
        ; Arrêter le robot
        MOV     R3, #0
        LDR     R6, =GPIO_PORTF_BASE + GPIO_O_DIR
        STR     R3, [R6]             ; Éteindre les LEDs
        BL      MOTEUR_DROIT_OFF
        BL      MOTEUR_GAUCHE_OFF

stop_loop
        B       stop_loop

handle_bumper
        ; Reculer brièvement
        BL      MOTEUR_DROIT_ARRIERE
        BL      MOTEUR_GAUCHE_ARRIERE

        ; Charger la valeur de `DUREE` en fonction du compteur SWITCH_COUNT_TWO
        LDR     R0, =SWITCH_COUNT_TWO
        LDR     R1, [R0]                   ; Charger la valeur actuelle du compteur

        CMP     R1, #0                     ; Si le compteur vaut 0
        BEQ     use_duree_one
        CMP     R1, #1                     ; Si le compteur vaut 1
        BEQ     use_duree_two
        CMP     R1, #2                     ; Si le compteur vaut 2
        BEQ     use_duree_three

        ; Réinitialiser le compteur à 0 si la valeur dépasse 2
        MOV     R1, #0
        STR     R1, [R0]
        B       use_duree_one              ; Revenir à la première configuration

use_duree_one
        LDR     R0, =DUREE_ONE
        LDR     R2, =DUREE_90_ONE
        LDR     R3, =DUREE_AVANCE_COURTE_ONE
        B       apply_duree

use_duree_two
        LDR     R0, =DUREE_TWO
        LDR     R2, =DUREE_90_TWO
        LDR     R3, =DUREE_AVANCE_COURTE_TWO
        B       apply_duree

use_duree_three
        LDR     R0, =DUREE_TRHEE
        LDR     R2, =DUREE_90_TRHEE
        LDR     R3, =DUREE_AVANCE_COURTE_TRHEE
        B       apply_duree

apply_duree
        ; Temporisation pour reculer
delay1
        SUBS    R0, R0, #1
        BNE     delay1

        ; Décider la direction de la rotation pour 180° (zigzag)
        CMP     R8, #0
        BEQ     turn_180_left

turn_180_right
        ; Rotation 90° à droite
        BL      MOTEUR_DROIT_ARRIERE
        BL      MOTEUR_GAUCHE_AVANT
        MOV     R0, R2                   ; Charger DUREE_90
delay2
        SUBS    R0, R0, #1
        BNE     delay2

        ; Avancer légèrement
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_AVANT
        MOV     R0, R3                   ; Charger DUREE_AVANCE_COURTE
delay3
        SUBS    R0, R0, #1
        BNE     delay3

        ; Rotation 90° à droite (complète 180°)
        BL      MOTEUR_DROIT_ARRIERE
        BL      MOTEUR_GAUCHE_AVANT
        MOV     R0, R2                   ; Charger DUREE_90
delay4
        SUBS    R0, R0, #1
        BNE     delay4

        ; Mettre à jour l'état
        MOV     R8, #0
        B       continue

turn_180_left
        ; Rotation 90° à gauche
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_ARRIERE
        MOV     R0, R2                   ; Charger DUREE_90
delay5
        SUBS    R0, R0, #1
        BNE     delay5

        ; Avancer légèrement
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_AVANT
        MOV     R0, R3                   ; Charger DUREE_AVANCE_COURTE
delay6
        SUBS    R0, R0, #1
        BNE     delay6

        ; Rotation 90° à gauche (complète 180°)
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_ARRIERE
        MOV     R0, R2                   ; Charger DUREE_90
delay7
        SUBS    R0, R0, #1
        BNE     delay7

        ; Mettre à jour l'état
        MOV     R8, #1
continue
        ; Reprendre la boucle
        B       loop
        nop
        END
