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

DUREE_TWO             EQU     0x03FFFFF
DUREE_90_TWO          EQU     0x800000
DUREE_AVANCE_COURTE_TWO EQU     0x00440000 ; Durée pour avancer légèrement
	
DUREE_TRHEE              EQU     0x03FFFFF
DUREE_90_TRHEE            EQU     0x800000
DUREE_AVANCE_COURTE_TRHEE  EQU     0x00440000 ; Durée pour avancer légèrement

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


		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
        ldr r0, = PORT45 	
        str r0, [r6]
		
        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = PORT45 		
        str r0, [r6]
 
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensité de sortie (2mA)
        ldr r0, = PORT45
        str r0, [r6]

              					;; pour eteindre LED
     
		; allumer la led broche 4 (PIN4)
		mov r3, #PORT45      					;; Allume portF broche 4 : 00010000
		ldr r6, = GPIO_PORTF_BASE + (PORT45<<2)  ;; @data Register = @base + (mask<<2) ==> LED1
		str r3, [r6] 
; pour eteindre LED

 		mov r2, #0x000
		
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
        SUBS    R1, R1, #1
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
        mov r2, #0x000       					;; pour eteindre LED
        LDR     R6, =GPIO_PORTF_BASE + GPIO_O_DIR
        STR     R2, [R6]             ; Éteindre les LEDs
        BL      MOTEUR_DROIT_OFF
        BL      MOTEUR_GAUCHE_OFF


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
