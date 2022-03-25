- [v1.24](#v124)
  - [Updated Instructions](#updated-instructions)
    - [v1.24.0.0 更新内容](#v12400)

# Updated Instructions

在此版本会重构环境变量参数项统一放在 `group_vars` 内管理。

会对部分 include 文件进行整合, 避免因迭代过程中新添加的文件与老文件放置不统一以及混乱的问题。