# Notes 

1. how do we configure to have the ability to attach into the node. Docker params:  
    * `stdin_open` - true 
    * `tty` - true

2. Right now I've hard coded all ports into the service. However, it'd be great to have either _host_ for `network_mode` - 
OR - configurable ports to open
   
3. Can we utilize `.env` file as opposed to  manually setting configs (I'll look into this!)

4. I really like the makefile and am thinking of implementing it for us - thoughts

5. When we are done, I want Joe/Troy to take a look and decide what they want to keep  / remove

