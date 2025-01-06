	AREA    |.text|, CODE, READONLY

SYSCTL_PERIPH_GPIOF EQU     0x400FE108

GPIO_PORTF_BASE     EQU     0x40025000
GPIO_PORTE_BASE     EQU     0x40024000
GPIO_PORTD_BASE		EQU		0x40007000

GPIO_O_DIR          EQU     0x400
GPIO_O_DR2R         EQU     0x500
GPIO_O_DEN          EQU     0x51C
GPIO_PUR            EQU     0x510

; LED
PORT45              EQU     0x30
PORT5               EQU     0x20
PORT4               EQU     0x10

; Switchs
PORT67				EQU		0xC0
PORT7				EQU		0x80
PORT6				EQU		0x40

; Bumper
PORT01              EQU     0x03
PORT0               EQU     0x01
PORT1               EQU     0x02

NOL2D               EQU     0x00
LED1                EQU     0x10

DUREE               EQU     0x002FFFFF
DUREE_90            EQU     0x3470EE
DUREE_AVANCE_COURTE EQU     0x00400000 ; Durée pour avancer légèrement


; Constantes
INCREMENT_CYCLE     EQU     0x00FFFFFF    ; Incrément de 10 secondes (valeur à ajuster)
BASE_DURATION       EQU     0x00FFFFFF    ; Durée initiale du cycle (valeur à ajuster)

SWITCH_COUNT        EQU     0x20000000    ; Adresse mémoire pour le compteur Switch
CURRENT_DURATION    EQU     0x20000004    ; Adresse mémoire pour la durée configurée

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
        STR     R1, [R0]               ; Initialisation du compteur de Switch

        LDR     R0, =CURRENT_DURATION
        LDR     R1, =BASE_DURATION
        STR     R1, [R0]               ; Initialisation de la durée à BASE_DURATION
		
        ldr r6, = SYSCTL_PERIPH_GPIOF
        mov r0, #0x00000038
        str r0, [r6]

        nop
        nop
        nop

        ; Configuration des LED (Port F)
        ldr r6, = GPIO_PORTF_BASE + GPIO_O_DIR
        ldr r0, = PORT45
        str r0, [r6]

        ldr r6, = GPIO_PORTF_BASE + GPIO_O_DEN
        ldr r0, = PORT45
        str r0, [r6]

        ldr r6, = GPIO_PORTF_BASE + GPIO_O_DR2R
        ldr r0, = PORT45
        str r0, [r6]

        ; Initialisation des bumpers (Port E)
        ldr r7, = GPIO_PORTE_BASE + GPIO_O_DEN
        ldr r0, = PORT01
        str r0, [r7]
;pull up 
        ldr r7, = GPIO_PORTE_BASE + GPIO_PUR
        ldr r0, = PORT01
        str r0, [r7]
;;;;;;;;;;;;;;;;;;;;;
		; Digital  - Port D

		ldr r7, = GPIO_PORTD_BASE+GPIO_O_DEN	
        ldr r0, = PORT67		
        str r0, [r7]	

		;  registre  SWITCHS

		ldr r7, = GPIO_PORTD_BASE+GPIO_PUR	
        ldr r0, = PORT67
        str r0, [r7]
			
;;;;;;;;;;;;;;;;;;;			
        ; Initialisation des moteurs
        BL      MOTEUR_INIT
        BL      MOTEUR_DROIT_ON
        BL      MOTEUR_GAUCHE_ON

        ; Initialisation de l'état (0 = gauche, 1 = droite)
        mov r8, #0


loop
		 ; Lire l'état du Switch 1
        LDR     R7, =GPIO_PORTD_BASE + (PORT6 << 2)
        LDR     R5, [R7]
        CMP     R5, #0x40            ; Switch 1 activé ?
        BEQ     increment_duration   ; Si oui, incrémenter la durée

        ; Lire la durée restante
        LDR     R0, =CURRENT_DURATION
        LDR     R1, [R0]
        CMP     R1, #0               ; Durée expirée ?
        BEQ     stop_robot           ; Si oui, arrêter le robot

        ; Réduire la durée actuelle
        SUBS    R1, R1, #1000
        STR     R1, [R0]
		
	 ;r7 voir si il et touche
        ; Lecture de l'état des bumpers mult decalage  
        ldr r7, = GPIO_PORTE_BASE + (PORT0 << 2)
        ldr r5, [r7]                ; État du bumper droit

        ldr r9, = GPIO_PORTE_BASE + (PORT1 << 2)
        ldr r10, [r9]               ; État du bumper gauche

        ; Vérifier les états et ajuster les moteurs/LED
        cmp r5, #0x01               ; Bumper droit activé ?
        bne handle_bumper

        cmp r10, #0x02              ; Bumper gauche activé ?
        bne handle_bumper
		


;        ldr r7, = GPIO_PORTD_BASE + (PORT6 << 2)
;        ldr r5, [r7]                ; État du bumper droit

;        ldr r9, = GPIO_PORTD_BASE + (PORT7 << 2)
;        ldr r10, [r9]               ; État du bumper gauche

;        ; Vérifier les états et ajuster les moteurs/LED
;        cmp r5, #0x40              ; Bumper droit activé ?
;        bne handle_switch1
;		
;        cmp r10, #0x80              ; Bumper gauche activé ?
;        bne handle_switch2
		
		

        ; Sinon, avancer tout droit
        mov r3, #PORT45
        ldr r6, = GPIO_PORTF_BASE + (PORT45 << 2)
        str r3, [r6]                ; Allume les LEDs
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_AVANT
		
		

        b       loop

increment_duration
        ; Charger INCREMENT_CYCLE dans un registre
        LDR     R2, =INCREMENT_CYCLE
        LDR     R0, =CURRENT_DURATION
        LDR     R1, [R0]
        ADD     R1, R1, R2              ; Ajouter INCREMENT_CYCLE à la durée actuelle
        STR     R1, [R0]
        B       loop

stop_robot
        ; Éteindre les LEDs et arrêter les moteurs
        MOV     R3, #0
        LDR     R6, =GPIO_PORTF_BASE + (PORT45 << 2)
        STR     R3, [R6]             ; Éteindre les LEDs
        BL      MOTEUR_DROIT_OFF 
        BL      MOTEUR_GAUCHE_OFF 

        ; Boucle d'attente
stop_loop
        B       stop_loop
	

handle_bumper
        ; Reculer brièvement
        BL      MOTEUR_DROIT_ARRIERE
        BL      MOTEUR_GAUCHE_ARRIERE
        ldr r0, = DUREE             ; Temporisation pour reculer
delay1
        subs r0, r0, #1
        bne delay1

        ; Décider la direction de la rotation pour 180° (zigzag)
        cmp r8, #0
        beq turn_180_left

turn_180_right
        ; Rotation 90° à droite
        BL      MOTEUR_DROIT_ARRIERE
        BL      MOTEUR_GAUCHE_AVANT
        ldr r0, = DUREE_90
delay2
        subs r0, r0, #1
        bne delay2

        ; Avancer légèrement
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_AVANT
        ldr r0, = DUREE_AVANCE_COURTE
delay3
        subs r0, r0, #1
        bne delay3

        ; Rotation 90° à droite (complète 180°)
        BL      MOTEUR_DROIT_ARRIERE
        BL      MOTEUR_GAUCHE_AVANT
        ldr r0, = DUREE_90
delay4
        subs r0, r0, #1
        bne delay4

        ; Mettre à jour l'état
        mov r8, #0
        b       continue

turn_180_left
        ; Rotation 90° à gauche
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_ARRIERE
        ldr r0, = DUREE_90
delay5
        subs r0, r0, #1
        bne delay5

        ; Avancer légèrement
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_AVANT
        ldr r0, = DUREE_AVANCE_COURTE
delay6
        subs r0, r0, #1
        bne delay6

        ; Rotation 90° à gauche (complète 180°)
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_ARRIERE
        ldr r0, = DUREE_90
delay7
        subs r0, r0, #1
        bne delay7

        ; Mettre à jour l'état
        mov r8, #1

continue
        ; Reprendre la boucle
        b       loop

        nop
        END
