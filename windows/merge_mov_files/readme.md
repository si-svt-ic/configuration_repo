# Nối Tệp Video MOV

Để nối các tệp video MOV, bạn có thể sử dụng các công cụ và phần mềm phổ biến sau:

## 1. Sử dụng **FFmpeg** (Công cụ dòng lệnh)

https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl-shared.zip

### Cách làm:

1. **Tạo một tệp danh sách** (ví dụ: `filelist.txt`) với nội dung như sau:
file 'video1.mov' 
file 'video2.mov' 
file 'video3.mov'

- Lưu ý: Đảm bảo các tệp video bạn muốn nối có định dạng giống nhau (cùng codec, độ phân giải, v.v.).

2. **Chạy lệnh FFmpeg**:
Mở terminal hoặc command prompt và sử dụng lệnh sau để nối các tệp:
```bash
ffmpeg -f concat -safe 0 -i filelist.txt -c copy output.mov

-f concat: Định dạng nối các tệp.
-safe 0: Cho phép sử dụng đường dẫn file không an toàn (tùy chọn).
-i filelist.txt: Chỉ định tệp danh sách chứa các tệp video.
-c copy: Sao chép các codec mà không cần mã hóa lại.
-output.mov: Tên tệp đầu ra.