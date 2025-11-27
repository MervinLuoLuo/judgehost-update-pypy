# judgehost Update pypy

多个 judgehost 容器下省事的脚本

------
快速使用:
1. 打开脚本看注释进行修改
2. 保存后把脚本放到 docker 的机子上
3. `chmod +x ./run.sh` 给权限
4. 把下载好的 pypy 编译器放到和这个脚本同目录下
5. 运行命令`./run.sh <container name> <max>`
> 这里要求一堆 judgehost 的容器应该统一命名, 比如judgehost-0,judgehost-1,那么 `<container name>` 就是 judgehost, `<max>` 就是1
