import rospy
from std_msgs.msg import Float64, Bool
from geometry_msgs.msg import Twist
import matplotlib.pyplot as plt
import matplotlib.animation as animation

rospy.sleep(5)  # Kurze Pause vor der Initialisierung

# Listen für die Speicherung der empfangenen Daten
offset_data = []
alpha_data = []
inside_row_data = []
linear_vel_data = []
angular_vel_data = []

# Funktionen, die aufgerufen werden, wenn eine Nachricht empfangen wird (Subscriber Callbacks)
def offset_callback(data):
    offset_data.append(data.data)  # Fügt den empfangenen Offset-Daten zur entsprechenden Liste hinzu

def alpha_callback(data):
    alpha_data.append(data.data)  # Fügt die empfangenen Alpha-Daten zur entsprechenden Liste hinzu

def inside_row_callback(data):
    inside_row_data.append(1 if data.data else 0)  # Fügt den empfangenen Inside-Row-Daten zur entsprechenden Liste hinzu

def cmd_vel_callback(data):
    linear_vel_data.append(data.linear.x)  # Fügt die empfangenen Daten für die lineare Geschwindigkeit zur Liste hinzu
    angular_vel_data.append(data.angular.z)  # Fügt die empfangenen Daten für die Winkelgeschwindigkeit zur Liste hinzu

# Initialisiert einen ROS-Knoten mit dem Namen 'live_plot_node'
rospy.init_node('live_plot_node')

# Initialisiert die Subscriber, die auf die angegebenen Themen hören und die angegebenen Callback-Funktionen aufrufen
rospy.Subscriber('/offset', Float64, offset_callback)
rospy.Subscriber('/alpha', Float64, alpha_callback)
rospy.Subscriber('/inside_row', Bool, inside_row_callback)
rospy.Subscriber('/cmd_vel', Twist, cmd_vel_callback)

# Initialisiert das Plot-Fenster mit fünf Subplots
fig, axs = plt.subplots(5, sharex=True, figsize=(8, 12))

# Funktion, die bei jedem Update des Animationsplots aufgerufen wird
def animate(i, axs):
    # Für jeden Subplot: die Daten plotten, Titel setzen, Grafik löschen für das nächste Update
    axs[0].clear()
    axs[0].plot(offset_data)
    axs[0].set_title('Offset')

    axs[1].clear()
    axs[1].plot(alpha_data)
    axs[1].set_title('Alpha')

    axs[2].clear()
    axs[2].plot(inside_row_data)
    axs[2].set_title('Inside Row')

    axs[3].clear()
    axs[3].plot(linear_vel_data)
    axs[3].set_title('Linear Velocity')

    axs[4].clear()
    axs[4].plot(angular_vel_data)
    axs[4].set_title('Angular Velocity')

    plt.tight_layout()  # Sorgt für angemessenen Platz zwischen den Subplots

# Initialisiert die Animation mit der Funktion animate und einem Intervall von 1000 Millisekunden
ani = animation.FuncAnimation(fig, animate, fargs=(axs,), interval=1000)

plt.show()  # Zeigt das Plot-Fenster an

# Spin: Erlaubt ROS, eingehende Nachrichten zu verarbeiten und die entsprechenden Callbacks aufzurufen
rospy.spin()

