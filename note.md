
open:
[<800147b0>] (unwind_backtrace+0x0/0xf8) from [<80011afc>] (show_stack+0x10/0x14)
[<80011afc>] (show_stack+0x10/0x14) from [<8001f1dc>] (warn_slowpath_common+0x4c/0x6c)
[<8001f1dc>] (warn_slowpath_common+0x4c/0x6c) from [<8001f218>] (warn_slowpath_null+0x1c/0x24)
[<8001f218>] (warn_slowpath_null+0x1c/0x24) from [<7f000084>] (led_open+0x38/0x60 [led_drv])
[<7f000084>] (led_open+0x38/0x60 [led_drv]) from [<800bbf5c>] (chrdev_open+0xb0/0x17c)
[<800bbf5c>] (chrdev_open+0xb0/0x17c) from [<800b68d0>] (do_dentry_open.isra.14+0x1d8/0x258)
[<800b68d0>] (do_dentry_open.isra.14+0x1d8/0x258) from [<800b6a20>] (finish_open+0x20/0x38)
[<800b6a20>] (finish_open+0x20/0x38) from [<800c4b58>] (do_last.isra.46+0x500/0xb8c)
[<800c4b58>] (do_last.isra.46+0x500/0xb8c) from [<800c5290>] (path_openat+0xac/0x458)
[<800c5290>] (path_openat+0xac/0x458) from [<800c58f0>] (do_filp_open+0x2c/0x80)
[<800c58f0>] (do_filp_open+0x2c/0x80) from [<800b78c0>] (do_sys_open+0xe4/0x170)
[<800b78c0>] (do_sys_open+0xe4/0x170) from [<8000e180>] (ret_fast_syscall+0x0/0x30)

write
[<800147b0>] (unwind_backtrace+0x0/0xf8) from [<80011afc>] (show_stack+0x10/0x14)
[<80011afc>] (show_stack+0x10/0x14) from [<8001f1dc>] (warn_slowpath_common+0x4c/0x6c)
[<8001f1dc>] (warn_slowpath_common+0x4c/0x6c) from [<8001f218>] (warn_slowpath_null+0x1c/0x24)
[<8001f218>] (warn_slowpath_null+0x1c/0x24) from [<7f0000e4>] (led_write+0x38/0xc8 [led_drv])
[<7f0000e4>] (led_write+0x38/0xc8 [led_drv]) from [<800b852c>] (vfs_write+0xb0/0x18c)
[<800b852c>] (vfs_write+0xb0/0x18c) from [<800b88e8>] (SyS_write+0x3c/0x70)
[<800b88e8>] (SyS_write+0x3c/0x70) from [<8000e180>] (ret_fast_syscall+0x0/0x30)


close
[<800147b0>] (unwind_backtrace+0x0/0xf8) from [<80011afc>] (show_stack+0x10/0x14)
[<80011afc>] (show_stack+0x10/0x14) from [<8001f1dc>] (warn_slowpath_common+0x4c/0x6c)
[<8001f1dc>] (warn_slowpath_common+0x4c/0x6c) from [<8001f218>] (warn_slowpath_null+0x1c/0x24)
[<8001f218>] (warn_slowpath_null+0x1c/0x24) from [<7f000044>] (led_close+0x34/0x3c [led_drv])
[<7f000044>] (led_close+0x34/0x3c [led_drv]) from [<800b92c8>] (__fput+0x8c/0x1fc)
[<800b92c8>] (__fput+0x8c/0x1fc) from [<8003959c>] (task_work_run+0xac/0xe8)
[<8003959c>] (task_work_run+0xac/0xe8) from [<80011738>] (do_work_pending+0xa4/0xa8)
[<80011738>] (do_work_pending+0xa4/0xa8) from [<8000e1c0>] (work_pending+0xc/0x20)
