	AREA    |.text|, CODE, READONLY  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BASE GPIO

; Definition des adresses de base des périphérique gpio
SYSCTL_PERIPH_GPIOF EQU     0x400FE108  ; Adresse pour activer le périphérique GPIOF
GPIO_PORTF_BASE     EQU     0x40025000  ; Adresse de base du port GPIO F (leds)
GPIO_PORTE_BASE     EQU     0x40024000  ; Adresse de base du port GPIO E (Bumpers)
GPIO_PORTD_BASE     EQU     0x40007000  ; Adresse de base du port GPIO D (Switches)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;REGISTRE

; Definition des offset pour les registre gpio
GPIO_O_DIR          EQU     0x400  ; Offset pour  la direction des broches
GPIO_O_DR2R         EQU     0x500  ; Offset pour  la résistance de sortie (2mA)
GPIO_O_DEN          EQU     0x51C  ; Offset pour activer les broches en mode numérique
GPIO_PUR            EQU     0x510  ; Offset pour activer les résistances de pull-up
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BROCHES

; Definition des masques pour les broches des LEDs
PORT45              EQU     0x30  ; Masque pour les broches 4 et 5 (Led1 et led2)
PORT5               EQU     0x20  ; Masque pour la broche 5 (Led2)
PORT4               EQU     0x10  ; Masque pour la broche 4 (Led1)

; Definition des masques pour les interrupteurs (switches)
PORT67              EQU     0xC0  ; Masque pour les broches 6 et 7 (Switches 1 et 2)
PORT7               EQU     0x80  ; Masque pour la broche 7 (Switche 2)
PORT6               EQU     0x40  ; Masque pour la broche 6 (Switche 1)

; Definition des masques pour les capteurs (bumpers)
PORT01              EQU     0x03  ; Masque pour les broches 0 et 1 (Bumper 1 et 2)
PORT0               EQU     0x01  ; Masque pour la broche 0 (Bumper 1)
PORT1               EQU     0x02  ; Masque pour la broche 1 (Bumper 2)
DUREE EQU     0x03FFFFF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DUREE

; Définition des durées pour la temporisation


; Durées pour une rotation de 90 selon la vitesse
; One Two Three pour les vitesses 1 2 3 
DUREE_90_ONE        EQU     0x800000    ; Durée pour SPEED_UN
DUREE_90_TWO        EQU     0x400000   ; Durée pour SPEED_TWO
DUREE_90_THREE      EQU     0x225000   ; Durée pour SPEED_THREE
	
DUREE_ONE               EQU     0x03FFFFF
DUREE_AVANCE_COURTE_ONE EQU     0x00440000 ; Durée pour avancer légèrement aprés le 1 er 90

DUREE_TWO             EQU     0x03FFFFF
DUREE_AVANCE_COURTE_TWO EQU     0x00440000 ; Durée pour avancer légèrement aprés le 1 er 90
	
DUREE_TRHEE              EQU     0x03FFFFF
DUREE_AVANCE_COURTE_THREE  EQU     0x00440000 ; Durée pour avancer légèrement aprés le 1 er 90

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CONSTANTES CYCLES

; Définition des constantes pour les cycles
; Environ 10 s 
INCREMENT_CYCLE     EQU     0x00FFFFF   ; Pour Incrémenté la durée initiale
BASE_DURATION       EQU     0x00FFFFF   ; Durée initiale du cycle
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CONSTANTES VITESSES

; Définition des vitesses des moteurs
; Seront necessaire lors de moteur_init cf moteur.s 
SPEED_UN            EQU     0x123  ; Vitesse 1
SPEED_TWO           EQU     0x53   ; Vitesse 2
SPEED_THREE         EQU     0x23   ; Vitesse 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Section de donnee en read/write
        AREA    |.data|, DATA, READWRITE
;DCD por aloué zone mémoire
SWITCH_COUNT        DCD     0x0             ; Compteur pour les cycles
CURRENT_DURATION    DCD     BASE_DURATION   ; Durée actuelle du cycle
SWITCH_COUNT_TWO    DCD     0x0             ; Deuxième compteur pour La vitesses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        AREA    |.text|, CODE, READONLY

        ENTRY
        EXPORT  __main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;IMPORTS

		; Importe les fonctions pour contrôler les moteurs 
        IMPORT  MOTEUR_INIT          
        IMPORT  MOTEUR_DROIT_ON
        IMPORT  MOTEUR_DROIT_OFF
        IMPORT  MOTEUR_DROIT_AVANT
        IMPORT  MOTEUR_DROIT_ARRIERE
        IMPORT  MOTEUR_GAUCHE_ON
        IMPORT  MOTEUR_GAUCHE_OFF
        IMPORT  MOTEUR_GAUCHE_AVANT
        IMPORT  MOTEUR_GAUCHE_ARRIERE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
__main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;MEMORY

        ; Initialisation de la mémoire que l'on a déclarer avec DCD
        LDR     R0, =SWITCH_COUNT
        MOV     R1, #0
        STR     R1, [R0]  ; Initialise le compteur SWITCH_COUNT à 0

        LDR     R0, =CURRENT_DURATION
        LDR     R1, =BASE_DURATION
        STR     R1, [R0]  ; Initialise la durée actuelle à BASE_DURATION

        LDR     R0, =SWITCH_COUNT_TWO
        MOV     R1, #0
        STR     R1, [R0]  ; Initialise le compteur SWITCH_COUNT_TWO à 0
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GPIOF
		
        ; Activer GPIOF avec délai pour stabilisation
        LDR     R6, =SYSCTL_PERIPH_GPIOF
        MOV     R0, #0x00000038
        STR     R0, [R6]  ; Active le périphérique GPIOF
		
		;DElAIS apres l'activation
		;HYPER IMPORTANT J'AI PASSE 1 semaine à debug ça ( ça marché en debug mais pas en mode realese)
		NOP
		NOP
		NOP
        MOV     R0, #0xFFFF
delay_init
        SUBS    R0, R0, #1
        BNE     delay_init  ; Boucle de temporisation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CONFIG LEDS

        ; Configuration des broches GPIO pour les LEDs
        LDR     R6, =GPIO_PORTF_BASE+GPIO_O_DIR
        LDR     R0, =PORT45
        STR     R0, [R6]  ; Configure les broches 4 et 5 en sortie

        LDR     R6, =GPIO_PORTF_BASE+GPIO_O_DEN
        LDR     R0, =PORT45
        STR     R0, [R6]  ; Active les broches en mode numérique

        LDR     R6, =GPIO_PORTF_BASE+GPIO_O_DR2R
        LDR     R0, =PORT45
        STR     R0, [R6]  ; Configure la résistance de sortie à 2mA

        ; Allumer la LED sur la broche 4
        MOV     R3, #PORT45
        LDR     R6, =GPIO_PORTF_BASE + (PORT45<<2)
        STR     R3, [R6]  ; Allume la LED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CONFIG BUMPERS

        ; Configuration des broches GPIO pour les bumpers (Port E)
        LDR     R7, =GPIO_PORTE_BASE + GPIO_O_DEN
        LDR     R0, =PORT01
        STR     R0, [R7]  ; Active les broches 0 et 1 en mode numérique

        ; Activation des résistances de pull-up pour les bumpers
        LDR     R7, =GPIO_PORTE_BASE + GPIO_PUR
        LDR     R0, =PORT01
        STR     R0, [R7]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CONFIG SWITCHES

        ; Configuration des broches GPIO pour les switches (Port D)
        LDR     R7, =GPIO_PORTD_BASE + GPIO_O_DEN
        LDR     R0, =PORT67
        STR     R0, [R7]  ; Active les broches 6 et 7 en mode numérique

        ; Activation des résistances de pull-up 
        LDR     R7, =GPIO_PORTD_BASE + GPIO_PUR
        LDR     R0, =PORT67
        STR     R0, [R7]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CONFIG MOTEURS

        ; Initialisation des moteurs
        LDR     R12, =SPEED_UN
        BL      MOTEUR_INIT
        BL      MOTEUR_DROIT_ON
        BL      MOTEUR_GAUCHE_ON

        ; Initialisation de l'état (0 = gauche, 1 = droite)
        MOV     R8, #0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;TEST ETAT SWITCHES
        ; Lecture de l'état des interrupteurs
        LDR     R12, =GPIO_PORTD_BASE + (PORT6 << 2)
        LDR     R11, [R12]  ; Lit l'état du switch 6
        CMP     R11, #0x40  ; Vérifie si le switch 6 est activé
        BNE     increment_duration  ; Si oui, incrémente la durée

        LDR     R12, =GPIO_PORTD_BASE + (PORT7 << 2)
        LDR     R11, [R12]  ; Lit l'état du switch 7
        CMP     R11, #0x80  ; Vérifie si le switch 7 est activé
        BNE     update_speed  ; Si oui, met à jour la vitesse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GESTION TIMER CYCLE 

        ; Lire la durée restante
        LDR     R0, =CURRENT_DURATION
        LDR     R1, [R0]
        CMP     R1, #0  ; Vérifie si la durée est écoulée
        BEQ     stop_robot  ; Si oui, arrête le robot

        ; Réduire la durée actuelle
        SUBS    R1, R1, #1
        STR     R1, [R0]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;TEST ETAT BUMPER

        ; Lecture des états des bumpers
        LDR     R7, =GPIO_PORTE_BASE + (PORT0 << 2)
        LDR     R5, [R7]  ; Lit l'état du bumper droit
        LDR     R9, =GPIO_PORTE_BASE + (PORT1 << 2)
        LDR     R10, [R9]  ; Lit l'état du bumper gauche

        ; Vérifier les états des bumpers
        CMP     R5, #0x01  ; Bumper droit activé ?
        BNE     handle_bumper
        CMP     R10, #0x02  ; Bumper gauche activé ?
        BNE     handle_bumper
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DEFAULT

        ; Sinon, avancer tout droit
        MOV     R3, #PORT45
        LDR     R6, =GPIO_PORTF_BASE + GPIO_O_DIR
        STR     R3, [R6]  ; Allume les LEDs
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_AVANT

        B       loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GESTION Speed
update_speed
        ; Incrementation du compteur du switche2
        LDR     R0, =SWITCH_COUNT_TWO
        LDR     R1, [R0]
        ADD     R1, R1, #1
        STR     R1, [R0]

        ; Verifier la valeur du compteur et definir la vitesse
        CMP     R1, #0  ; Si le compteur vaut 0
        BEQ     set_speed_one
        CMP     R1, #1  ; Si le compteur vaut 1
        BEQ     set_speed_two
        CMP     R1, #2  ; Si le compteur vaut 2
        BEQ     set_speed_three

        ; Réinitialiser le compteur à 0 si la valeur depasse 2
        MOV     R1, #0
        STR     R1, [R0]
        B       set_speed_one  ; Revenir à la vitesse 1

set_speed_one
        LDR     R12, =SPEED_UN  ; Charger la vitesse 1
        B       apply_speed

set_speed_two
        LDR     R12, =SPEED_TWO  ; Charger la vitesse 2
        B       apply_speed

set_speed_three
        LDR     R12, =SPEED_THREE  ; Charger la vitesse 3

apply_speed
        ; Configurer les moteurs avec la vitesse sélectionnée
        BL      MOTEUR_INIT
        BL      MOTEUR_DROIT_ON
        BL      MOTEUR_GAUCHE_ON
        B       loop  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GESTION CYCLE
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
        MOV     R2, #0x000  ; Éteindre les LEDs
        LDR     R6, =GPIO_PORTF_BASE + GPIO_O_DIR
        STR     R2, [R6]
        BL      MOTEUR_DROIT_OFF
        BL      MOTEUR_GAUCHE_OFF

stop_loop
        B       stop_loop  ; Boucle infinie pour arrêter le robot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GESTION BUMPER
handle_bumper
        ; Reculer brièvement
        BL      MOTEUR_DROIT_ARRIERE
        BL      MOTEUR_GAUCHE_ARRIERE
        LDR     R0, =DUREE  ; Temporisation pour reculer (identique pour toutes les vitesses)
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

        ; Charger la durée de rotation en fonction de la vitesse active
        LDR     R0, =SWITCH_COUNT_TWO
        LDR     R1, [R0]
        CMP     R1, #0
        BEQ     load_duration_one
        CMP     R1, #1
        BEQ     load_duration_two
        CMP     R1, #2
        BEQ     load_duration_three

load_duration_one
        LDR     R0, =DUREE_90_ONE
        B       apply_duration

load_duration_two
        LDR     R0, =DUREE_90_TWO
        B       apply_duration

load_duration_three
        LDR     R0, =DUREE_90_THREE

apply_duration
        ; Appliquer la durée de rotation
delay2
        SUBS    R0, R0, #1
        BNE     delay2

        ; Avancer légèrement
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_AVANT

        ; Charger la durée d'avance en fonction de la vitesse active
        LDR     R0, =SWITCH_COUNT_TWO
        LDR     R1, [R0]
        CMP     R1, #0
        BEQ     load_avance_one
        CMP     R1, #1
        BEQ     load_avance_two
        CMP     R1, #2
        BEQ     load_avance_three

load_avance_one
        LDR     R0, =DUREE_AVANCE_COURTE_ONE
        B       apply_avance

load_avance_two
        LDR     R0, =DUREE_AVANCE_COURTE_TWO
        B       apply_avance

load_avance_three
        LDR     R0, =DUREE_AVANCE_COURTE_THREE

apply_avance
        ; Appliquer la durée d'avance
delay3
        SUBS    R0, R0, #1
        BNE     delay3

        ; Rotation 90° à droite (complète 180°)
        BL      MOTEUR_DROIT_ARRIERE
        BL      MOTEUR_GAUCHE_AVANT

        ; Recharger la durée de rotation en fonction de la vitesse active
        LDR     R0, =SWITCH_COUNT_TWO
        LDR     R1, [R0]
        CMP     R1, #0
        BEQ     load_duration_one_2
        CMP     R1, #1
        BEQ     load_duration_two_2
        CMP     R1, #2
        BEQ     load_duration_three_2

load_duration_one_2
        LDR     R0, =DUREE_90_ONE
        B       apply_duration_2

load_duration_two_2
        LDR     R0, =DUREE_90_TWO
        B       apply_duration_2

load_duration_three_2
        LDR     R0, =DUREE_90_THREE

apply_duration_2
        ; Appliquer la durée de rotation
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

        ; Charger la durée de rotation en fonction de la vitesse active
        LDR     R0, =SWITCH_COUNT_TWO
        LDR     R1, [R0]
        CMP     R1, #0
        BEQ     load_duration_one_left
        CMP     R1, #1
        BEQ     load_duration_two_left
        CMP     R1, #2
        BEQ     load_duration_three_left

load_duration_one_left
        LDR     R0, =DUREE_90_ONE
        B       apply_duration_left

load_duration_two_left
        LDR     R0, =DUREE_90_TWO
        B       apply_duration_left

load_duration_three_left
        LDR     R0, =DUREE_90_THREE

apply_duration_left
        ; Appliquer la durée de rotation
delay5
        SUBS    R0, R0, #1
        BNE     delay5

        ; Avancer légèrement
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_AVANT

        ; Charger la durée d'avance en fonction de la vitesse active
        LDR     R0, =SWITCH_COUNT_TWO
        LDR     R1, [R0]
        CMP     R1, #0
        BEQ     load_avance_one_left
        CMP     R1, #1
        BEQ     load_avance_two_left
        CMP     R1, #2
        BEQ     load_avance_three_left

load_avance_one_left
        LDR     R0, =DUREE_AVANCE_COURTE_ONE
        B       apply_avance_left

load_avance_two_left
        LDR     R0, =DUREE_AVANCE_COURTE_TWO
        B       apply_avance_left

load_avance_three_left
        LDR     R0, =DUREE_AVANCE_COURTE_THREE

apply_avance_left
        ; Appliquer la durée d'avance
delay6
        SUBS    R0, R0, #1
        BNE     delay6

        ; Rotation 90° à gauche (complète 180°)
        BL      MOTEUR_DROIT_AVANT
        BL      MOTEUR_GAUCHE_ARRIERE

        ; Recharger la durée de rotation en fonction de la vitesse active
        LDR     R0, =SWITCH_COUNT_TWO
        LDR     R1, [R0]
        CMP     R1, #0
        BEQ     load_duration_one_left_2
        CMP     R1, #1
        BEQ     load_duration_two_left_2
        CMP     R1, #2
        BEQ     load_duration_three_left_2

load_duration_one_left_2
        LDR     R0, =DUREE_90_ONE
        B       apply_duration_left_2

load_duration_two_left_2
        LDR     R0, =DUREE_90_TWO
        B       apply_duration_left_2

load_duration_three_left_2
        LDR     R0, =DUREE_90_THREE

apply_duration_left_2
        ; Appliquer la durée de rotation
delay7
        SUBS    R0, R0, #1
        BNE     delay7

        ; Mettre à jour l'état
        MOV     R8, #1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

continue
        ; Reprendre la boucle principale
        B       loop

        END
