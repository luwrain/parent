import curses
import os
import signal
import time
from player import cplayer

Key_close_first = "KEY_F(1)"
key_up = "KEY_UP"
key_down = "KEY_DOWN"
    

def stop_player(player):
    player.stop

def play_part(part):
    if part < 10:
        media = cplayer(f"0{part}.mp3")
        media.play
        
    else:
        media = cplayer(f"{part}.mp3")
        media.play

    return media

def if_exist(part):
    if part < 10:
        if os.path.exists(f'0{part}.txt'):
            return True
        else:
            return False
    else:
        if os.path.exists(f'{part}.txt'):
            return True
        else:
            return False


def file_opend_and_print(stdscr, part):
    if part < 10:
        with open(f'0{part}.txt', 'r') as f:
            lines = f.read().splitlines()
        lines_to_str = " ".join(lines)
        str_chunks = [lines_to_str[i:i+screen_collums//2] for i in range(0, len(lines_to_str), screen_collums//2)]
        for i in range(len(str_chunks)):
            stdscr.addstr(5+i, (screen_collums//2) // 2, str_chunks[i])

    else:
        with open(f'{part}.txt', 'r') as f:
            lines = f.read().splitlines()
        lines_to_str = " ".join(lines)
        str_chunks = [lines_to_str[i:i+screen_collums//2] for i in range(0, len(lines_to_str), screen_collums//2)]
        for i in range(len(str_chunks)):
            stdscr.addstr(5+i, (screen_collums//2) // 2, str_chunks[i])

def show_slide(stdscr, part):
    play = play_part(part)
    part_i = part
    stdscr.clear()
    stdscr.refresh()
    file_opend_and_print(stdscr, part)
    stdscr.refresh()
    while True:
        key = stdscr.getkey()
        if key == key_down:
            if if_exist(part_i + 1):
                part_i += 1
                stop_player(play)
                show_slide(stdscr, part_i)
                return
        if key == key_up:
            if if_exist(part_i - 1):
                part_i -= 1
                stop_player(play)
                show_slide(stdscr, part_i)
        

def main(stdscr):
    play = play_part(0)
    stdscr.clear()
    stdscr.refresh()
    file_opend_and_print(stdscr, 0)
    stdscr.refresh()
    while True:
        key = stdscr.getkey()
        if key == Key_close_first:
            stop_player(play)
            show_slide(stdscr, 1)
            return
        


stdscr = curses.initscr()
curses.noecho()
curses.cbreak()
stdscr.keypad(True)
screen_lines = curses.LINES
screen_collums = curses.COLS


main(stdscr)


curses.nocbreak()
stdscr.keypad(False)
curses.echo()
curses.endwin()
print("exiting")