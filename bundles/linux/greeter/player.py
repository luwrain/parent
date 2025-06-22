import subprocess
import time

class cplayer():

    def __init__(self, name_of_file):
        self.path_to_file = name_of_file

    @property
    def play(self):
        cmd = f"cvlc {self.path_to_file}"
        global process
        process = subprocess.Popen(cmd, shell=True)
        return 0

    @property
    def stop(self):
        process.kill()
        kilproc = subprocess.Popen('killall vlc', shell=True)
        time.sleep(1)
        kilproc.kill()


if __name__ == '__main__':
    play = cplayer('00.mp3')
    play.play
    time.sleep(3)
    play.stop