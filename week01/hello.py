"""
week01/hello.py — prove you can write Python, not just run it.

Requirements for this file (see the Week 1 assignment):
  * read a name with input()
  * use an f-string
  * use a list
  * use a for-loop

Ten lines is plenty. Replace the TODOs with your own code.

Run with:
    python week01/hello.py
"""


import sys

def main() -> None:
    print("Python " + sys.version.split()[0])

    # Read the user's name
    name = input("Enter your name: ")

    # Store football players and their ratings
    players = ["Messi", "Ronaldo", "Mbappe", "Haaland", "Salah"]
    ratings = [95, 94, 92, 91, 90]

    # Show the football scouting list
    print(f"\n{name}'s football scouting list:")

    # Loop through the players and display their ratings
    for i in range(len(players)):
        print(f"{players[i]} - Rating: {ratings[i]}/100")

if __name__ == "__main__":
    main()

    