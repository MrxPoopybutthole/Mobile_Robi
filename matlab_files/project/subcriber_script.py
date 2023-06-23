import rospy
from std_msgs.msg import Float64, Bool
from geometry_msgs.msg import Twist
import matplotlib.pyplot as plt
import matplotlib.animation as animation

rospy.sleep(5)

# Erstellen von Listen, um die empfangenen Daten zu speichern
offset_data = []
alpha_data = []
inside_row_data = []
linear_vel_data = []
angular_vel_data = []

# Subscriber Callback-Funktionen
def offset_callback(data):
    offset_data.append(data.data)

def alpha_callback(data):
    alpha_data.append(data.data)

def inside_row_callback(data):
    inside_row_data.append(1 if data.data else 0)

def cmd_vel_callback(data):
    linear_vel_data.append(data.linear.x)
    angular_vel_data.append(data.angular.z)

# Initialisieren von ROS node
rospy.init_node('live_plot_node')

# Initialisieren von Subscribers
rospy.Subscriber('/offset', Float64, offset_callback)
rospy.Subscriber('/alpha', Float64, alpha_callback)
rospy.Subscriber('/inside_row', Bool, inside_row_callback)
rospy.Subscriber('/cmd_vel', Twist, cmd_vel_callback)

# Initialisieren von Plot
fig, axs = plt.subplots(5, sharex=True, figsize=(8, 12))

def animate(i, axs):
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

    plt.tight_layout()  # Hinzugefügter Befehl für den Abstand zwischen den Plots

ani = animation.FuncAnimation(fig, animate, fargs=(axs,), interval=1000)

plt.show()

# Spin
rospy.spin()

