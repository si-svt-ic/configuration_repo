https://quoc9x.com/2023/06/03/kiem-tra-ket-noi-tcp-udp-voi-netcat-va-nmap/


Linux, Other

Kiểm tra kết nối TCP/UDP với netcat và nmap

Ngày: 3 Tháng Sáu, 2023Author: quocnvc
0 Bình luận
1. netcat

Syntax chung

1
nc <options> host port
Một số options

-z: thực hiện scan thay vì cố gắng bắt đầu kết nối.

-v: yêu cầu netcat cung cấp thêm thông tin chi tiết, -vv sẽ hiển thị thông tin chi tiết hơn nữa.

-n: để chỉ định rằng bạn không cần phân giải địa chỉ IP bằng DNS, quá trình scan sẽ diễn ra nhanh hơn vì không cần dùng DNS.

-w: đặt thời gian timeout cho mỗi kết nối (s).

-u: sử dụng giao thức UDP (mặc định netcat dùng TCP).

Trên hầu hết các hệ thống, chúng ta có thể sử dụng một trong hai lệnh netcat hoặc nc thay thế cho nhau. Chúng là alias cho cùng một lệnh.

Kiểm tra kết nối TCP

1
nc -zvn -w 1 IP port
Kiểm tra kết nối UDP

1
nc -zvu -w 1 IP port
Scan một dải port

Bạn có thể thay thế port bằng một dải port trong lệnh netcat để thực hiện scan

Ví dụ để scan từ port 1 => 1000 sử dụng giao thức TCP.

1
nc -zvn -w 1 IP 1-1000
2. nmap

Install (On Ubuntu)

1
apt install nmap
Syntax chung

1
nmap <options> host
Một số options

-sT: Thực hiện quét TCP (thực hiện việc bắt tay 3 bước).

-sU: Thực hiện quét UDP.

-sS: Quét TCP nửa mở (sẽ quét nhanh hơn so với việc bắt tay 3 bước).

-p: chỉ định một port hoặc một dải port để quét.

-v: verbose, nhận nhiều thông tin trả về hơn khi scan.

Trạng thái trả về của các port trong lệnh nmap

Open: Đang có một dịch vụ thực hiện kết nối ra bên ngoài nhưng không bị giám sát bởi tường lửa.
Closed: Máy mục tiêu vẫn nhận và phản hồi, nhưng ko có ứng dụng nào đang nghe trên cổng đó. Khi đó cổng được báo là đóng vẫn có thể cho ta biết host đang sống.
Filtered: Đã có sự ngăn chặn bởi tường lửa, bạn sẽ chẳng nhận được bất cứ phản hồi gì từ mục tiêu cả.
Unfiltered: Không bị chặn, nhưng không thể biết được cổng đóng hay mở.
Open/Filtered: không biết là cổng mở hay bị lọc. Nó xảy ra đối với kiểu quét mà cổng dù mở nhưng không phản hồi gì cả nên biểu hiện của nó giống như bị lọc.
Closed/Filtered: Trạng thái xuất hiện khi Nmap không biết được port đó đang Closed hay Filtered. Nó được sử dụng cho quét IPID Idle.
Check một port cụ thể (mặc định sử dụng TCP)

1
nmap -p [port] [target]
Check kết nối TCP, nmap sẽ thực hiện việc bắt tay 3 bước, mặc định sẽ quét từ port 1 => 1000

1
nmap -sT [target]
(Nếu không có option -p mặc định namp sẽ quét từ port 1 => 1000).

Quét kết nối TCP với 1 port cụ thể

1
nmap -sT -p [port] [target]
Quét kết nối UDP với 1 port cụ thể

1
nmap -sU -p [port] [target]
Trong option -p bạn có thể thay thế port bằng một dải port để quét

Ví dụ để quét từ port 1 => 100 sử dụng giao thức TCP

1
nmap -sT -p 1-100 [target]
Best Regards,