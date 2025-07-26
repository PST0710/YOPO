#!/bin/bash

# 脚本路径：YOPO/run_all.sh
# 确保在YOPO根目录下执行此脚本

# 获取当前脚本所在目录（YOPO根目录）
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 函数：在指定目录执行命令
run_in_directory() {
  local dir="$1"
  local title="$2"
  local command="$3"
  local delay="$4"
  
  gnome-terminal --tab --title="$title" \
    -- bash -c "cd '$dir'; $command; sleep $delay; exec bash"
}

# 1. 启动控制器节点（最先启动，可能包含roscore）
run_in_directory "$SCRIPT_DIR/Controller" "Controller" \
  "source devel/setup.bash; roslaunch so3_quadrotor_simulator simulator_attitude_control.launch" 1

# 2. 启动传感器模拟器（等待控制器启动完成）
run_in_directory "$SCRIPT_DIR/Simulator" "Sensor Simulator" \
  "source devel/setup.bash; rosrun sensor_simulator sensor_simulator_cuda" 3

# 3. 启动YOPO算法节点（等待其他ROS节点启动）
run_in_directory "$SCRIPT_DIR/YOPO" "YOPO Algorithm" \
  "source ~/anaconda3/etc/profile.d/conda.sh; conda activate yopo;  python test_yopo_ros.py --trial=1 --epoch=50" 2

# 4. 启动RViz可视化（最后启动）
run_in_directory "$SCRIPT_DIR/YOPO" "RViz Visualization" \
  "rviz -d yopo.rviz" 1

echo "所有节点已启动！请检查各个终端标签页。"