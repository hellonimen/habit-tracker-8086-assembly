.MODEL SMALL
.386
.STACK 100H

; Character I/O (INT 21H, AH=01H, 02H, 08H, 09H)
; File operations (INT 21H, AH=3CH, 3DH, 3EH, 3FH, 40H)
; System time (INT 21H, AH=2CH)
; Program termination (INT 21H, AH=4CH)


.DATA
    ; Core data storage - supports 10 habits
    habits       DB 150 DUP(0)           ; 10 habits * 15 chars each
    streaks      DB 10 DUP(0)            ; Current streaks
    best_streaks DB 10 DUP(0)            ; Best streaks ever
    habit_count  DB 0                    ; Number of habits
    total_marks  DB 0                    ; Total completions

    ; Menu messages
    title_msg    DB '============================', 13, 10
                 DB '    H A B I T   T R A C K E R', 13, 10
                 DB '   Your Success Journey!', 13, 10
                 DB '============================', 13, 10, 13, 10, '$'
    
    menu_msg     DB '+---------------------------+', 13, 10
                 DB '|         M E N U           |', 13, 10  
                 DB '+---------------------------+', 13, 10
                 DB '| 1-Add    2-Mark   3-View  |', 13, 10
                 DB '| 4-Delete 5-Reset  6-Stats |', 13, 10
                 DB '| 7-Analytics  8-Exit       |', 13, 10
                 DB '| 9-*RANKING*  0-*REWARDS*  |', 13, 10
                 DB '| M-**MOTIVATIONAL QUOTES** |', 13, 10
                 DB '| S-*SAVE*     L-*LOAD*     |', 13, 10
                 DB '| R-*REPORT*                |', 13, 10
                 DB '| *FEATURES: 2,5,6,7,9,0,M  |', 13, 10
                 DB '+---------------------------+', 13, 10
                 DB 'Choice: $'

    ; Basic prompts
    habit_prompt DB 13, 10, 'Enter habit name: $'
    num_prompt   DB 13, 10, 'Choose habit number: $'
    success_msg  DB 13, 10, '*** SUCCESS! ***', 13, 10, '$'
    error_msg    DB 13, 10, '*** ERROR! Invalid choice! ***', 13, 10, '$'
    full_msg     DB 13, 10, 'Cannot add more habits! (Max 10)', 13, 10, '$'
    empty_msg    DB 13, 10, 'No habits found! Add some first.', 13, 10, '$'
    continue_msg DB 13, 10, 'Press any key to continue...', '$'
    
    ; Details messages
    select_habit DB 13, 10, 'Select a habit to view details:', 13, 10, '$'
    habit_detail DB 13, 10, '=== HABIT DETAILS ===', 13, 10, '$'
    current_str  DB 13, 10, 'Current Streak: $'
    best_str     DB 13, 10, 'Best Streak: $'
    days_str     DB ' days', 13, 10, '$'
    
    ; Reset feature
    reset_menu   DB 13, 10, '*** ADDITIONAL FEATURE: RESET ***', 13, 10
                 DB 'RESET OPTIONS:', 13, 10
                 DB '1-Reset this habit', 13, 10
                 DB '2-Reset ALL habits', 13, 10
                 DB '3-Cancel', 13, 10
                 DB 'Choice: $'
    reset_all_msg DB 13, 10, 'ALL habits reset!', 13, 10, '$'
    reset_one_msg DB 13, 10, 'Habit streak reset!', 13, 10, '$'
    
    ; Delete messages
    delete_confirm DB 13, 10, 'Delete this habit? (y/n): $'
    cancelled_msg  DB 13, 10, 'Cancelled.', 13, 10, '$'
    
    ; Analytics feature
    analytics_title DB 13, 10, '*** ADDITIONAL FEATURE: ANALYTICS ***', 13, 10
                    DB '=== CALCULATIONS & STATS ===', 13, 10, '$'
    completion_rate DB 13, 10, 'Completion Rate: $'
    percent_msg     DB '%', 13, 10, '$'
    
    ; Statistics feature
    stats_header    DB 13, 10, '*** ADDITIONAL FEATURE: STATISTICS ***', 13, 10, '$'
    
    ; Achievement feature
    achievement_header DB 13, 10, '*** ADDITIONAL FEATURE: ACHIEVEMENTS ***', 13, 10, '$'
    
    ; Ranking feature
    ranking_header DB 13, 10, '*** NEW FEATURE: HABIT RANKING ***', 13, 10
                   DB 'Top 3 Habits by Best Streak:', 13, 10
                   DB '==============================', 13, 10, '$'
    rank1_msg      DB 'GOLD MEDAL: ', '$'
    rank2_msg      DB 'SILVER MEDAL: ', '$'
    rank3_msg      DB 'BRONZE MEDAL: ', '$'
    no_rank_msg    DB 'Not enough habits for ranking!', 13, 10, '$'
    
    ; Rewards feature
    rewards_header DB 13, 10, '*** NEW FEATURE: STREAK REWARDS ***', 13, 10
                   DB 'Your Achievement Badges:', 13, 10
                   DB '========================', 13, 10, '$'
    badge_rookie   DB '* ROOKIE BADGE (1+ day streak)', 13, 10, '$'
    badge_warrior  DB '** WARRIOR BADGE (5+ day streak)', 13, 10, '$'
    badge_legend   DB '*** LEGEND BADGE (10+ day streak)', 13, 10, '$'
    no_badges      DB 'No badges earned yet! Keep going!', 13, 10, '$'
    
    ; Motivational quotes feature
    motiv_header   DB 13, 10, '*** NEW FEATURE: MOTIVATIONAL AI ***', 13, 10
                   DB 'Your Daily Inspiration:', 13, 10
                   DB '=======================', 13, 10, '$'
    quote1         DB '"Every day is a fresh start!"', 13, 10, '$'
    quote2         DB '"Small steps lead to big changes!"', 13, 10, '$'
    quote3         DB '"You are stronger than you think!"', 13, 10, '$'
    quote4         DB '"Progress, not perfection!"', 13, 10, '$'
    quote5         DB '"Believe in yourself!"', 13, 10, '$'
    keep_going     DB 13, 10, 'Keep building those habits! You got this!', 13, 10, '$'
    
    ; Display formatting
    newline      DB 13, 10, '$'
    name_sep     DB '. $'
    streak_info  DB ' - Current: $'
    best_info    DB ' | Best: $'
    days_end     DB ' days', 13, 10, '$'
    
    ; Input buffer
    input_buf    DB 16, ?, 16 DUP(0)
    
    filename        DB 'habits.txt', 0
    file_handle     DW 0
    file_error_msg  DB 13, 10, 'File error occurred!', 13, 10, '$'
    save_success    DB 13, 10, 'Data saved successfully!', 13, 10, '$'
    load_success    DB 13, 10, 'Data loaded successfully!', 13, 10, '$'
    file_buffer     DB 170 DUP(0)

    ; Report feature 
    report_filename DB 'report.txt', 0
    report_header   DB '============================', 13, 10
                    DB '    HABIT TRACKER REPORT', 13, 10
                    DB '============================', 13, 10
                    DB 'Date: 22/7/2025', 13, 10, 13, 10, '$'
    report_footer   DB 13, 10, '============================', 13, 10, '$'
    report_success  DB 13, 10, 'Report generated successfully!', 13, 10
                    DB 'Check report.txt file.', 13, 10, '$'
    
    report_header_text   DB '=== HABIT TRACKER REPORT ===', 13, 10, 13, 10, '$'
    report_footer_text   DB 13, 10, '=== END OF REPORT ===', 13, 10, '$'
    streak_text          DB ' - Current Streak: $'       

    report_line_buffer  DB 80 DUP(0)    
    
        
    ;  1 - Authentication
    login_prompt        DB 'Enter Password: $'
    access_granted_msg  DB 'Access Granted!', 13, 10, '$'
    access_denied       DB 'Access Denied!', 13, 10, '$'
    
    ; Enhanced authentication system
    stored_password_hash DB 30H         ; Pre-stored hash of "admin" 
    user_input_buffer   DB 10 DUP(0)    ; Store user input
    input_length        DB 0             ; Track input length
    temp_hash           DB 0             ; Temporary hash calculation
    
    ; 5 - Decimal values  
    cost_prompt     DB 'Enter cost (RM10.50): $'
    sample_cost     DB 'RM15.75$'
    habit_costs     DB 150 DUP('0')  ; Store costs as strings

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    CALL LOGIN_SYSTEM
    
    CALL LOAD_DATA_SILENT    

MENU_LOOP:
    LEA DX, title_msg
    MOV AH, 09H
    INT 21H
    
    CMP habit_count, 0
    JE SKIP_DISPLAY
    CALL SHOW_HABIT_LIST

SKIP_DISPLAY:
    LEA DX, menu_msg
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    
    CMP AL, '1'
    JNE CHK2
    JMP ADD_SECTION
CHK2:
    CMP AL, '2'
    JNE CHK3
    JMP MARK_SECTION
CHK3:
    CMP AL, '3'
    JNE CHK4
    JMP VIEW_SECTION
CHK4:
    CMP AL, '4'
    JNE CHK5
    JMP DELETE_SECTION
CHK5:
    CMP AL, '5'
    JNE CHK6
    JMP RESET_SECTION
CHK6:
    CMP AL, '6'
    JNE CHK7
    JMP STATS_SECTION
CHK7:
    CMP AL, '7'
    JNE CHK8
    JMP ANALYTICS_SECTION
CHK8:
    CMP AL, '8'
    JNE CHK9
    JMP EXIT_PROGRAM
CHK9:
    CMP AL, '9'
    JNE CHK0
    CALL RANKING_FEATURE
    JMP MENU_LOOP
CHK0:
    CMP AL, '0'
    JNE CHKM
    CALL REWARDS_FEATURE
    JMP MENU_LOOP
CHKM:
    CMP AL, 'M'
    JE DO_MOTIV
    CMP AL, 'm'
    JNE CHKS
   
DO_MOTIV:
    CALL MOTIVATIONAL_QUOTES
    JMP MENU_LOOP
    
CHKS:               
    CMP AL, 'S'
    JNE CHKR
    CALL SAVE_DATA
    CALL WAIT_KEY
    JMP MENU_LOOP
    
CHKR:               
    CMP AL, 'R'
    JNE CHKL
    CALL GENERATE_REPORT
    CALL WAIT_KEY
    JMP MENU_LOOP

CHKL:               
    CMP AL, 'L'
    JNE ERROR_CHOICE
    CALL LOAD_DATA
    CALL WAIT_KEY
    JMP MENU_LOOP

ERROR_CHOICE:
    LEA DX, error_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

; ADD HABIT
ADD_SECTION:
    CMP habit_count, 10
    JB ADD_OK
    LEA DX, full_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

ADD_OK:
    LEA DX, habit_prompt
    MOV AH, 09H
    INT 21H
    
    LEA DX, input_buf
    MOV AH, 0AH
    INT 21H
    
    CMP BYTE PTR [input_buf + 1], 0
    JE ADD_ERROR
    
    MOV AL, habit_count
    MOV AH, 0
    MOV BL, 15
    MUL BL
    LEA DI, habits
    ADD DI, AX
    
    PUSH DI
    MOV CX, 15
    MOV AL, 0
CLEAR_LOOP:
    MOV [DI], AL
    INC DI
    DEC CX
    JNZ CLEAR_LOOP
    POP DI
    
    LEA SI, input_buf + 2
    MOV CL, [input_buf + 1]
    MOV CH, 0
    
COPY_LOOP:
    CMP CX, 0
    JE COPY_DONE
    LODSB
    MOV [DI], AL
    INC DI
    DEC CX
    JMP COPY_LOOP
    
COPY_DONE:
    MOV BYTE PTR [DI], '$'
    
    MOV BL, habit_count
    MOV BH, 0
    MOV streaks[BX], 0
    MOV best_streaks[BX], 0
    
    INC habit_count
    
    LEA DX, success_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

ADD_ERROR:
    LEA DX, error_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

; MARK HABIT
MARK_SECTION:
    CMP habit_count, 0
    JA MARK_OK
    LEA DX, empty_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

MARK_OK:
    CALL SHOW_HABIT_LIST
    LEA DX, num_prompt
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    SUB AL, '1'
    
    CMP AL, 0
    JB MARK_ERROR
    CMP AL, habit_count
    JAE MARK_ERROR
    
    MOV BL, AL
    MOV BH, 0
    
    ; Prevent overflow - don't go above 99
    CMP streaks[BX], 99
    JAE NO_INCREMENT
    INC streaks[BX]
    INC total_marks

NO_INCREMENT:
    MOV AL, streaks[BX]
    CMP AL, best_streaks[BX]
    JLE NO_UPDATE_BEST
    MOV best_streaks[BX], AL
    
    MOV AL, streaks[BX]
    CMP AL, best_streaks[BX]
    JLE NO_UPDATE_BEST
    MOV best_streaks[BX], AL

NO_UPDATE_BEST:
    LEA DX, success_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

MARK_ERROR:
    LEA DX, error_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

; VIEW SECTION
VIEW_SECTION:
    CMP habit_count, 0
    JA VIEW_OK
    LEA DX, empty_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

VIEW_OK:
    LEA DX, select_habit
    MOV AH, 09H
    INT 21H
    
    CALL SHOW_HABIT_NAMES
    
    LEA DX, num_prompt
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    SUB AL, '1'
    
    CMP AL, 0
    JB VIEW_ERROR
    CMP AL, habit_count
    JAE VIEW_ERROR
    
    CALL SHOW_HABIT_DETAILS
    CALL WAIT_KEY
    JMP MENU_LOOP

VIEW_ERROR:
    LEA DX, error_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

; DELETE SECTION
DELETE_SECTION:
    CMP habit_count, 0
    JA DELETE_OK
    LEA DX, empty_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

DELETE_OK:
    CALL SHOW_HABIT_LIST
    LEA DX, num_prompt
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    SUB AL, '1'
    
    CMP AL, 0
    JB DELETE_ERROR
    CMP AL, habit_count
    JAE DELETE_ERROR
    
    LEA DX, delete_confirm
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    CMP AL, 'y'
    JE CONFIRM_DELETE
    CMP AL, 'Y'
    JE CONFIRM_DELETE
    
    LEA DX, cancelled_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

CONFIRM_DELETE:
    DEC habit_count
    
    LEA DX, success_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

DELETE_ERROR:
    LEA DX, error_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

; RESET SECTION
RESET_SECTION:
    CMP habit_count, 0
    JA RESET_OK
    LEA DX, empty_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

RESET_OK:
    LEA DX, reset_menu
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    
    CMP AL, '1'
    JE RESET_ONE
    CMP AL, '2'
    JE RESET_ALL
    CMP AL, '3'
    JE RESET_CANCEL
    JMP RESET_ERROR

RESET_ONE:
    CALL SHOW_HABIT_LIST
    LEA DX, num_prompt
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    SUB AL, '1'
    
    CMP AL, 0
    JB RESET_ERROR
    CMP AL, habit_count
    JAE RESET_ERROR
    
    MOV BL, AL
    MOV BH, 0
    MOV streaks[BX], 0
    
    LEA DX, reset_one_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

RESET_ALL:
    MOV BL, 0
    MOV CL, habit_count

RESET_ALL_LOOP:
    CMP CL, 0
    JE RESET_ALL_DONE
    MOV streaks[BX], 0
    INC BL
    DEC CL
    JMP RESET_ALL_LOOP

RESET_ALL_DONE:
    LEA DX, reset_all_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

RESET_CANCEL:
    LEA DX, cancelled_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

RESET_ERROR:
    LEA DX, error_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

; STATS SECTION
STATS_SECTION:
    LEA DX, stats_header
    MOV AH, 09H
    INT 21H
    
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    MOV DL, 'T'
    MOV AH, 02H
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'l'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'H'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'b'
    INT 21H
    MOV DL, 'i'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, habit_count
    ADD DL, '0'
    INT 21H
    
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    MOV DL, 'T'
    MOV AH, 02H
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'l'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'M'
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 'r'
    INT 21H
    MOV DL, 'k'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    
    MOV AL, total_marks
    CMP AL, 10
    JB SINGLE_DIGIT_MARKS
    
    MOV AH, 0
    MOV BL, 10
    DIV BL
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    MOV AL, AH
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    JMP MARKS_DONE

SINGLE_DIGIT_MARKS:
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

MARKS_DONE:
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    CALL WAIT_KEY
    JMP MENU_LOOP


    
    ; NEW CODE - Bit operations demonstration
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    ; Display "Bit Operations Demo:"
    MOV DL, 'B'
    MOV AH, 02H
    INT 21H
    MOV DL, 'i'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'O'
    INT 21H
    MOV DL, 'p'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    
    ; Use bit operations on habit_count
    MOV AL, habit_count
    SHL AL, 1           ; Multiply by 2 using shift
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    
    MOV AL, total_marks
    SHR AL, 1           ; Divide by 2 using shift
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    ; Continue with your existing completion_rate code...
    LEA DX, completion_rate
    MOV AH, 09H
    INT 21H

ANALYTICS_SECTION:
    CMP habit_count, 0
    JA ANALYTICS_OK
    LEA DX, empty_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP MENU_LOOP

ANALYTICS_OK:
    LEA DX, analytics_title
    MOV AH, 09H
    INT 21H
    
    ; NEW CODE - Bit operations demonstration
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    ; Display "Bit Operations Demo:"
    MOV DL, 'B'
    MOV AH, 02H
    INT 21H
    MOV DL, 'i'
    INT 21H
    MOV DL, 't'
    INT 21H
    MOV DL, ' '
    INT 21H
    MOV DL, 'O'
    INT 21H
    MOV DL, 'p'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H
    
    ; Use bit operations on habit_count
    MOV AL, habit_count
    SHL AL, 1           ; Multiply by 2 using shift
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    MOV DL, ' '
    MOV AH, 02H
    INT 21H
    
    MOV AL, total_marks
    SHR AL, 1           ; Divide by 2 using shift
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    LEA DX, completion_rate
    MOV AH, 09H
    INT 21H
    
    ; Calculate: (current total streaks * 100) / (best possible streaks)
    ; This gives actual completion percentage
    MOV AL, 0
    MOV BL, 0
    MOV CL, habit_count
    
CALC_CURRENT_TOTAL:
    CMP CL, 0
    JE CALC_BEST_TOTAL
    ADD AL, streaks[BX]
    INC BX
    DEC CL
    JMP CALC_CURRENT_TOTAL
    
CALC_BEST_TOTAL:
    MOV BL, 0
    MOV CL, habit_count
    MOV DL, 0
    
CALC_BEST_LOOP:
    CMP CL, 0
    JE DO_PERCENTAGE
    ADD DL, best_streaks[BX]
    INC BX
    DEC CL
    JMP CALC_BEST_LOOP
    
DO_PERCENTAGE:
    CMP DL, 0
    JE ZERO_RATE
    
    ; AL = current total, DL = best total
    ; Calculate (AL * 100) / DL
    MOV AH, 0
    MOV BL, 100
    MUL BL          ; AX = current * 100
    DIV DL          ; AL = percentage
    
    CMP AL, 100
    JAE SHOW_100
    CMP AL, 10
    JAE TWO_DIGIT_ANALYTICS
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    JMP RATE_DONE

SHOW_100:
    MOV DL, '1'
    MOV AH, 02H
    INT 21H
    MOV DL, '0'
    INT 21H
    MOV DL, '0'
    INT 21H
    JMP RATE_DONE

TWO_DIGIT_ANALYTICS:
    MOV AH, 0
    MOV BL, 10
    DIV BL
    ADD AL, '0'
    MOV DL, AL
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    MOV AL, AH
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    JMP RATE_DONE

ZERO_RATE:
    MOV DL, '0'
    MOV AH, 02H
    INT 21H

RATE_DONE:
    LEA DX, percent_msg
    MOV AH, 09H
    INT 21H
    
    CALL WAIT_KEY
    JMP MENU_LOOP

    
    
; RANKING FEATURE - FIXED TO SORT HIGHEST TO LOWEST
RANKING_FEATURE PROC
    LEA DX, ranking_header
    MOV AH, 09H
    INT 21H
    
    CMP habit_count, 3
    JAE RANK_OK
    LEA DX, no_rank_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    RET

RANK_OK:
    MOV SI, 0FFH
    MOV DI, 0FFH
    MOV BP, 0FFH
    MOV AH, 0
    MOV AL, 0
    MOV BH, 0
    
    MOV CL, habit_count
    MOV CH, 0
    MOV BX, 0
FIND_TOP:                    
    CMP best_streaks[BX], AH
    JAE NEW_FIRST
    CMP best_streaks[BX], AL
    JAE NEW_SECOND
    CMP best_streaks[BX], BH
    JAE NEW_THIRD
    JMP NEXT_HABIT

NEW_FIRST:
    MOV BP, DI
    MOV BH, AL
    MOV DI, SI
    MOV AL, AH
    MOV SI, BX
    MOV AH, best_streaks[BX]
    JMP NEXT_HABIT
    
NEW_SECOND:
    MOV BP, DI
    MOV BH, AL
    MOV DI, BX
    MOV AL, best_streaks[BX]
    JMP NEXT_HABIT
    
NEW_THIRD:
    MOV BP, BX
    MOV BH, best_streaks[BX]
    
NEXT_HABIT:
    INC BX
    LOOP FIND_TOP
    
    CMP SI, 0FFH
    JE RANK_DONE
    LEA DX, rank1_msg
    MOV AH, 09H
    INT 21H
    MOV BX, SI
    CALL SHOW_HABIT_NAME_ONLY
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    CMP DI, 0FFH
    JE RANK_DONE
    LEA DX, rank2_msg
    MOV AH, 09H
    INT 21H
    MOV BX, DI
    CALL SHOW_HABIT_NAME_ONLY
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    CMP BP, 0FFH
    JE RANK_DONE
    LEA DX, rank3_msg
    MOV AH, 09H
    INT 21H
    MOV BX, BP
    CALL SHOW_HABIT_NAME_ONLY
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
RANK_DONE:
    CALL WAIT_KEY
    RET
RANKING_FEATURE ENDP

; REWARDS FEATURE
REWARDS_FEATURE PROC
    LEA DX, rewards_header
    MOV AH, 09H
    INT 21H
    
    MOV CL, habit_count
    CMP CL, 0
    JNE CHECK_BADGES
    LEA DX, no_badges
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    RET

CHECK_BADGES:
    MOV BX, 0
    MOV CH, 0
    
BADGE_LOOP:
    CMP best_streaks[BX], 10
    JB CHECK_WARRIOR
    MOV CH, 3
    JMP NEXT_BADGE
    
CHECK_WARRIOR:
    CMP best_streaks[BX], 5
    JB CHECK_ROOKIE
    CMP CH, 3
    JE NEXT_BADGE
    MOV CH, 2
    JMP NEXT_BADGE
    
CHECK_ROOKIE:
    CMP best_streaks[BX], 1
    JB NEXT_BADGE
    CMP CH, 0
    JNE NEXT_BADGE
    MOV CH, 1
    
NEXT_BADGE:
    INC BX
    DEC CL
    JNZ BADGE_LOOP
    
    CMP CH, 0
    JNE SHOW_BADGES
    LEA DX, no_badges
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    RET

SHOW_BADGES:
    CMP CH, 1
    JB BADGE_END
    LEA DX, badge_rookie
    MOV AH, 09H
    INT 21H
    
    CMP CH, 2
    JB BADGE_END
    LEA DX, badge_warrior
    MOV AH, 09H
    INT 21H
    
    CMP CH, 3
    JB BADGE_END
    LEA DX, badge_legend
    MOV AH, 09H
    INT 21H

BADGE_END:
    CALL WAIT_KEY
    RET
REWARDS_FEATURE ENDP

; MOTIVATIONAL QUOTES
MOTIVATIONAL_QUOTES PROC
    LEA DX, motiv_header
    MOV AH, 09H
    INT 21H
    
    MOV AH, 2CH
    INT 21H
    
    MOV AL, DL
    MOV BL, 5
    MOV AH, 0
    DIV BL
    
    CMP AH, 0
    JNE TRY_Q2
    LEA DX, quote1
    JMP SHOW_QUOTE
TRY_Q2:
    CMP AH, 1
    JNE TRY_Q3
    LEA DX, quote2
    JMP SHOW_QUOTE
TRY_Q3:
    CMP AH, 2
    JNE TRY_Q4
    LEA DX, quote3
    JMP SHOW_QUOTE
TRY_Q4:
    CMP AH, 3
    JNE SHOW_Q5
    LEA DX, quote4
    JMP SHOW_QUOTE
SHOW_Q5:
    LEA DX, quote5
    
SHOW_QUOTE:
    MOV AH, 09H
    INT 21H
    
    LEA DX, keep_going
    MOV AH, 09H
    INT 21H
    
    CALL WAIT_KEY
    RET
MOTIVATIONAL_QUOTES ENDP

; EXIT
EXIT_PROGRAM:

    CALL SAVE_DATA
    
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    MOV DL, 'G'
    MOV AH, 02H
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 'd'
    INT 21H
    MOV DL, 'b'
    INT 21H
    MOV DL, 'y'
    INT 21H
    MOV DL, 'e'
    INT 21H
    MOV DL, '!'
    INT 21H
    
    MOV AH, 4CH
    MOV AL, 0
    INT 21H

; UTILITY PROCEDURES
WAIT_KEY PROC
    LEA DX, continue_msg
    MOV AH, 09H
    INT 21H
    MOV AH, 01H
    INT 21H
    RET
WAIT_KEY ENDP

SHOW_HABIT_LIST PROC
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    MOV CL, habit_count
    CMP CL, 0
    JE SHOW_LIST_END
    
    MOV BL, 0

SHOW_LIST_LOOP:
    MOV DL, BL
    ADD DL, '1'
    MOV AH, 02H
    INT 21H
    
    LEA DX, name_sep
    MOV AH, 09H
    INT 21H
    
    PUSH BX
    PUSH CX
    MOV AL, BL
    MOV AH, 0
    MOV CL, 15
    MUL CL
    LEA DX, habits
    ADD DX, AX
    MOV AH, 09H
    INT 21H
    POP CX
    POP BX
    
    LEA DX, streak_info
    MOV AH, 09H
    INT 21H
    
    PUSH BX
    ;Display streaks with multi-digit support
    MOV AL, streaks[BX]
    CMP AL, 10
    JB SINGLE_CURRENT
    MOV AH, 0
    MOV BL, 10
    DIV BL
    ADD AL, '0'
    MOV DL, AL
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    MOV AL, AH
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    JMP CURRENT_DONE

SINGLE_CURRENT:
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

CURRENT_DONE:
    POP BX

    
    LEA DX, best_info
    MOV AH, 09H
    INT 21H
    
    PUSH BX
    ;Display best streaks with multi-digit support
    MOV AL, best_streaks[BX]
    CMP AL, 10
    JB SINGLE_BEST
    MOV AH, 0
    MOV BL, 10
    DIV BL
    ADD AL, '0'
    MOV DL, AL
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    MOV AL, AH
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    JMP BEST_DONE

SINGLE_BEST:
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

BEST_DONE:
    POP BX
    LEA DX, days_end
    MOV AH, 09H
    INT 21H
    
    INC BL
    DEC CL
    JNZ SHOW_LIST_LOOP

SHOW_LIST_END:
    RET
SHOW_HABIT_LIST ENDP

SHOW_HABIT_NAMES PROC
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    MOV CL, habit_count
    CMP CL, 0
    JE SHOW_NAMES_END
    
    MOV BL, 0

SHOW_NAMES_LOOP:
    MOV DL, BL
    ADD DL, '1'
    MOV AH, 02H
    INT 21H
    
    LEA DX, name_sep
    MOV AH, 09H
    INT 21H
    
    PUSH BX
    PUSH CX
    MOV AL, BL
    MOV AH, 0
    MOV CL, 15
    MUL CL
    LEA DX, habits
    ADD DX, AX
    MOV AH, 09H
    INT 21H
    POP CX
    POP BX
    
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    INC BL
    DEC CL
    JNZ SHOW_NAMES_LOOP

SHOW_NAMES_END:
    RET
SHOW_HABIT_NAMES ENDP

SHOW_HABIT_DETAILS PROC
    MOV BL, AL
    MOV BH, 0
    
    LEA DX, habit_detail
    MOV AH, 09H
    INT 21H
    
    PUSH BX
    MOV AL, BL
    MOV AH, 0
    MOV CL, 15
    MUL CL
    LEA DX, habits
    ADD DX, AX
    MOV AH, 09H
    INT 21H
    POP BX
    
    LEA DX, current_str
    MOV AH, 09H
    INT 21H
    
    ;Display current streak with multi-digit support
    MOV AL, streaks[BX]
    CMP AL, 10
    JB SINGLE_DETAIL_CURRENT
    MOV AH, 0
    MOV BL, 10
    DIV BL
    ADD AL, '0'
    MOV DL, AL
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    MOV AL, AH
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    JMP DETAIL_CURRENT_DONE

SINGLE_DETAIL_CURRENT:
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

DETAIL_CURRENT_DONE:
   
    
    LEA DX, days_str
    MOV AH, 09H
    INT 21H
    
    LEA DX, best_str
    MOV AH, 09H
    INT 21H
    
    ;Display best streak with multi-digit support
    MOV AL, best_streaks[BX]
    CMP AL, 10
    JB SINGLE_DETAIL_BEST
    MOV AH, 0
    MOV BL, 10
    DIV BL
    ADD AL, '0'
    MOV DL, AL
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    MOV AL, AH
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    JMP DETAIL_BEST_DONE

SINGLE_DETAIL_BEST:
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

DETAIL_BEST_DONE:
    LEA DX, days_str
    MOV AH, 09H
    INT 21H
    
    RET
SHOW_HABIT_DETAILS ENDP


; ===== SAVE DATA TO FILE =====
SAVE_DATA PROC
    MOV AH, 3CH
    MOV CX, 0
    LEA DX, filename
    INT 21H
    JC SAVE_ERROR
    
    MOV file_handle, AX
    CALL PREPARE_SAVE_BUFFER
    
    MOV AH, 40H
    MOV BX, file_handle
    MOV CX, 171
    LEA DX, file_buffer
    INT 21H
    JC SAVE_ERROR
    
    MOV AH, 3EH
    MOV BX, file_handle
    INT 21H
    
    LEA DX, save_success
    MOV AH, 09H
    INT 21H
    RET

SAVE_ERROR:
    LEA DX, file_error_msg
    MOV AH, 09H
    INT 21H
    RET
SAVE_DATA ENDP

; ===== LOAD DATA FROM FILE =====
LOAD_DATA PROC
    MOV AH, 3DH
    MOV AL, 0
    LEA DX, filename
    INT 21H
    JC LOAD_ERROR
    
    MOV file_handle, AX
    
    MOV AH, 3FH
    MOV BX, file_handle
    MOV CX, 171
    LEA DX, file_buffer
    INT 21H
    JC LOAD_ERROR
    
    MOV AH, 3EH
    MOV BX, file_handle
    INT 21H
    
    CALL RESTORE_LOAD_BUFFER
    
    LEA DX, load_success
    MOV AH, 09H
    INT 21H
    RET

LOAD_ERROR:
    LEA DX, file_error_msg
    MOV AH, 09H
    INT 21H
    RET
LOAD_DATA ENDP

; ===== SILENT LOAD FOR STARTUP =====
LOAD_DATA_SILENT PROC
    MOV AH, 3DH
    MOV AL, 0
    LEA DX, filename
    INT 21H
    JC LOAD_SILENT_END    ; Just return if file doesn't exist
    
    MOV file_handle, AX
    
    MOV AH, 3FH
    MOV BX, file_handle
    MOV CX, 171
    LEA DX, file_buffer
    INT 21H
    JC LOAD_SILENT_CLOSE
    
    CALL RESTORE_LOAD_BUFFER

LOAD_SILENT_CLOSE:
    MOV AH, 3EH
    MOV BX, file_handle
    INT 21H

LOAD_SILENT_END:
    RET
LOAD_DATA_SILENT ENDP

; ===== PREPARE DATA FOR SAVING =====
PREPARE_SAVE_BUFFER PROC
    MOV AL, habit_count
    MOV file_buffer[0], AL
    
    MOV BX, 0
    MOV DI, 1
    
FILE_SAVE_LOOP:
    CMP BL, habit_count
    JAE FILE_SAVE_COMPLETE
    
    PUSH BX
    PUSH DI
    
    MOV AL, BL
    MOV AH, 0
    MOV CL, 15
    MUL CL
    LEA SI, habits
    ADD SI, AX
    
    MOV CX, 15
FILE_COPY_NAME:
    MOV AL, [SI]
    MOV file_buffer[DI], AL
    INC SI
    INC DI
    DEC CX
    JNZ FILE_COPY_NAME
    
    POP DI
    POP BX
    ADD DI, 15
    
    MOV AL, streaks[BX]
    MOV file_buffer[DI], AL
    INC DI
    
    MOV AL, best_streaks[BX]
    MOV file_buffer[DI], AL
    INC DI
    
    INC BX
    JMP FILE_SAVE_LOOP

FILE_SAVE_COMPLETE:
    ; SAVE TOTAL_MARKS (ADD THIS TO FIX YOUR ISSUE)
    MOV AL, total_marks
    MOV file_buffer[DI], AL
    RET
PREPARE_SAVE_BUFFER ENDP

; ===== RESTORE DATA FROM LOADING =====
RESTORE_LOAD_BUFFER PROC
    MOV AL, file_buffer[0]
    MOV habit_count, AL
    
    MOV BX, 0
FILE_CLEAR_LOOP:
    CMP BL, 10
    JAE FILE_CLEAR_DONE
    MOV streaks[BX], 0
    MOV best_streaks[BX], 0
    INC BX
    JMP FILE_CLEAR_LOOP

FILE_CLEAR_DONE:
    MOV BX, 0
    MOV SI, 1
    
FILE_LOAD_LOOP:
    CMP BL, habit_count
    JAE FILE_LOAD_COMPLETE
    
    PUSH BX
    PUSH SI
    
    MOV AL, BL
    MOV AH, 0
    MOV CL, 15
    MUL CL
    LEA DI, habits
    ADD DI, AX
    
    MOV CX, 15
FILE_COPY_NAME_BACK:
    MOV AL, file_buffer[SI]
    MOV [DI], AL
    INC SI
    INC DI
    DEC CX
    JNZ FILE_COPY_NAME_BACK
    
    POP SI
    POP BX
    ADD SI, 15
    
    MOV AL, file_buffer[SI]
    MOV streaks[BX], AL
    INC SI
    
    MOV AL, file_buffer[SI]
    MOV best_streaks[BX], AL
    INC SI
    
    INC BX
    JMP FILE_LOAD_LOOP

FILE_LOAD_COMPLETE:
    ; RESTORE TOTAL_MARKS 
    MOV AL, file_buffer[SI]
    MOV total_marks, AL
    RET
RESTORE_LOAD_BUFFER ENDP

; ===== GENERATE READABLE REPORT =====

GENERATE_REPORT PROC
    CMP habit_count, 0
    JA SIMPLE_REPORT_OK
    LEA DX, empty_msg
    MOV AH, 09H
    INT 21H
    RET

SIMPLE_REPORT_OK:
    ; Create report file
    MOV AH, 3CH
    MOV CX, 0
    LEA DX, report_filename
    INT 21H
    JC SIMPLE_REPORT_ERROR
    
    MOV file_handle, AX
    
    ; Write header
    MOV AH, 40H
    MOV BX, file_handle
    MOV CX, 31
    LEA DX, report_header_text
    INT 21H
    
    ; Write a simple summary only (this definitely works)
    LEA SI, report_line_buffer
    MOV BYTE PTR [SI], 'T'
    MOV BYTE PTR [SI+1], 'o'
    MOV BYTE PTR [SI+2], 't'
    MOV BYTE PTR [SI+3], 'a'
    MOV BYTE PTR [SI+4], 'l'
    MOV BYTE PTR [SI+5], ':'
    MOV BYTE PTR [SI+6], ' '
    
    MOV AL, habit_count
    ADD AL, '0'
    MOV BYTE PTR [SI+7], AL
    
    MOV BYTE PTR [SI+8], ' '
    MOV BYTE PTR [SI+9], 'h'
    MOV BYTE PTR [SI+10], 'a'
    MOV BYTE PTR [SI+11], 'b'
    MOV BYTE PTR [SI+12], 'i'
    MOV BYTE PTR [SI+13], 't'
    MOV BYTE PTR [SI+14], 's'
    MOV BYTE PTR [SI+15], 13
    MOV BYTE PTR [SI+16], 10
    
    ; Write the summary line
    MOV AH, 40H
    MOV BX, file_handle
    MOV CX, 17
    LEA DX, report_line_buffer
    INT 21H
    
    ; Write footer
    MOV AH, 40H
    MOV BX, file_handle
    MOV CX, 21
    LEA DX, report_footer_text
    INT 21H
    
    ; Close file
    MOV AH, 3EH
    MOV BX, file_handle
    INT 21H
    
    LEA DX, report_success
    MOV AH, 09H
    INT 21H
    RET

SIMPLE_REPORT_ERROR:
    LEA DX, file_error_msg
    MOV AH, 09H
    INT 21H
    RET
GENERATE_REPORT ENDP

SHOW_HABIT_NAME_ONLY PROC
    PUSH BX
    MOV AL, BL
    MOV AH, 0
    MOV CL, 15
    MUL CL
    LEA DX, habits
    ADD DX, AX
    MOV AH, 09H
    INT 21H
    POP BX
    RET
SHOW_HABIT_NAME_ONLY ENDP

LOGIN_SYSTEM PROC
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    
    ; Display "Password: "
    MOV DL, 'P'
    MOV AH, 02H
    INT 21H
    MOV DL, 'a'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, 's'
    INT 21H
    MOV DL, 'w'
    INT 21H
    MOV DL, 'o'
    INT 21H
    MOV DL, 'r'
    INT 21H
    MOV DL, 'd'
    INT 21H
    MOV DL, ':'
    INT 21H
    MOV DL, ' '
    INT 21H

    ; Clear input buffer
    MOV CX, 10
    LEA DI, user_input_buffer
    MOV AL, 0
CLEAR_INPUT_BUFFER:
    MOV [DI], AL
    INC DI
    LOOP CLEAR_INPUT_BUFFER
    
    ; Reset input counter
    MOV input_length, 0
    LEA SI, user_input_buffer

PASSWORD_INPUT_LOOP:
    MOV AH, 08H         ; Get char without echo (MASKED!)
    INT 21H
    CMP AL, 13          ; Enter key?
    JE PROCESS_PASSWORD
    CMP AL, 8           ; Backspace?
    JE HANDLE_BACKSPACE_INPUT
    
    ; Store character and show asterisk
    CMP input_length, 9  ; Max 9 characters
    JAE PASSWORD_INPUT_LOOP
    
    MOV [SI], AL        ; Store actual character
    INC SI
    INC input_length
    
    MOV DL, '*'         ; Display asterisk instead
    MOV AH, 02H
    INT 21H
    JMP PASSWORD_INPUT_LOOP

HANDLE_BACKSPACE_INPUT:
    CMP input_length, 0
    JE PASSWORD_INPUT_LOOP       ; Nothing to delete
    DEC SI
    MOV BYTE PTR [SI], 0
    DEC input_length
    
    ; Visual backspace (space + backspace)
    MOV DL, 8           ; Backspace
    MOV AH, 02H
    INT 21H
    MOV DL, ' '         ; Space
    INT 21H
    MOV DL, 8           ; Backspace again
    INT 21H
    JMP PASSWORD_INPUT_LOOP

PROCESS_PASSWORD:
    CALL CALCULATE_HASH
    
    ; Compare with stored hash
    MOV AL, temp_hash
    CMP AL, stored_password_hash
    JE LOGIN_SUCCESS
    
    ; Access denied
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    LEA DX, access_denied
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    JMP LOGIN_SYSTEM    ; Try again

LOGIN_SUCCESS:
    LEA DX, newline
    MOV AH, 09H
    INT 21H
    LEA DX, access_granted_msg
    MOV AH, 09H
    INT 21H
    CALL WAIT_KEY
    RET
LOGIN_SYSTEM ENDP

CALCULATE_HASH PROC
    LEA SI, user_input_buffer
    MOV AL, 42H         ; Initialize hash seed
    MOV CL, input_length
    CMP CL, 0
    JE HASH_CALCULATION_DONE
    
HASH_CALCULATION_LOOP:
    XOR AL, [SI]        ; XOR with each character
    ROL AL, 1           ; Rotate left for mixing
    INC SI
    DEC CL
    JNZ HASH_CALCULATION_LOOP
    
HASH_CALCULATION_DONE:
    MOV temp_hash, AL
    RET
CALCULATE_HASH ENDP

MAIN ENDP
END MAIN