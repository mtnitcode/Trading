using OpenQA.Selenium.Chrome;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TradingAutomation
{
    public partial class FromChromeTest : Form
    {
        private IntPtr cmdPtr;
        private int ConsoleWidth;
        private IntPtr folderViewPtr;

        private const int SWP_NOOWNERZORDER = 0x200;
        private const int SWP_NOREDRAW = 0x8;
        private const int SWP_NOZORDER = 0x4;
        private const int SWP_SHOWWINDOW = 0x0040;
        private const int WS_EX_MDICHILD = 0x40;
        private const int SWP_FRAMECHANGED = 0x20;
        private const int SWP_NOACTIVATE = 0x10;
        private const int SWP_ASYNCWINDOWPOS = 0x4000;
        private const int SWP_NOMOVE = 0x2;
        private const int SWP_NOSIZE = 0x1;
        private const int GWL_STYLE = (-16);
        private const int GWL_EXSTYLE = (-20);
        private const int WS_VISIBLE = 0x10000000;
        private const int WM_CLOSE = 0x10;
        private const int WS_CHILD = 0x40000000;

        public abstract class WS
        {
            public const uint WS_OVERLAPPED = 0x00000000;
            public const uint WS_POPUP = 0x80000000;
            public const uint WS_CHILD = 0x40000000;
            public const uint WS_MINIMIZE = 0x20000000;
            public const uint WS_VISIBLE = 0x10000000;
            public const uint WS_DISABLED = 0x08000000;
            public const uint WS_CLIPSIBLINGS = 0x04000000;
            public const uint WS_CLIPCHILDREN = 0x02000000;
            public const uint WS_MAXIMIZE = 0x01000000;
            public const uint WS_CAPTION = 0x00C00000;     /* WS_BORDER | WS_DLGFRAME  */
            public const uint WS_BORDER = 0x00800000;
            public const uint WS_DLGFRAME = 0x00400000;
            public const uint WS_VSCROLL = 0x00200000;
            public const uint WS_HSCROLL = 0x00100000;
            public const uint WS_SYSMENU = 0x00080000;
            public const uint WS_THICKFRAME = 0x00040000;
            public const uint WS_GROUP = 0x00020000;
            public const uint WS_TABSTOP = 0x00010000;

            public const uint WS_MINIMIZEBOX = 0x00020000;
            public const uint WS_MAXIMIZEBOX = 0x00010000;

            public const uint WS_TILED = WS_OVERLAPPED;
            public const uint WS_ICONIC = WS_MINIMIZE;
            public const uint WS_SIZEBOX = WS_THICKFRAME;
            public const uint WS_TILEDWINDOW = WS_OVERLAPPEDWINDOW;

            // Common Window Styles

            public const uint WS_OVERLAPPEDWINDOW =
                (WS_OVERLAPPED |
                  WS_CAPTION |
                  WS_SYSMENU |
                  WS_THICKFRAME |
                  WS_MINIMIZEBOX |
                  WS_MAXIMIZEBOX);

            public const uint WS_POPUPWINDOW =
                (WS_POPUP |
                  WS_BORDER |
                  WS_SYSMENU);

            public const uint WS_CHILDWINDOW = WS_CHILD;

            //Extended Window Styles

            public const uint WS_EX_DLGMODALFRAME = 0x00000001;
            public const uint WS_EX_NOPARENTNOTIFY = 0x00000004;
            public const uint WS_EX_TOPMOST = 0x00000008;
            public const uint WS_EX_ACCEPTFILES = 0x00000010;
            public const uint WS_EX_TRANSPARENT = 0x00000020;

            //#if(WINVER >= 0x0400)
            public const uint WS_EX_MDICHILD = 0x00000040;
            public const uint WS_EX_TOOLWINDOW = 0x00000080;
            public const uint WS_EX_WINDOWEDGE = 0x00000100;
            public const uint WS_EX_CLIENTEDGE = 0x00000200;
            public const uint WS_EX_CONTEXTHELP = 0x00000400;

            public const uint WS_EX_RIGHT = 0x00001000;
            public const uint WS_EX_LEFT = 0x00000000;
            public const uint WS_EX_RTLREADING = 0x00002000;
            public const uint WS_EX_LTRREADING = 0x00000000;
            public const uint WS_EX_LEFTSCROLLBAR = 0x00004000;
            public const uint WS_EX_RIGHTSCROLLBAR = 0x00000000;

            public const uint WS_EX_CONTROLPARENT = 0x00010000;
            public const uint WS_EX_STATICEDGE = 0x00020000;
            public const uint WS_EX_APPWINDOW = 0x00040000;

            public const uint WS_EX_OVERLAPPEDWINDOW = (WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE);
            public const uint WS_EX_PALETTEWINDOW = (WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST);
            //#endif /* WINVER >= 0x0400 */

            //#if(_WIN32_WINNT >= 0x0500)
            public const uint WS_EX_LAYERED = 0x00080000;
            //#endif /* _WIN32_WINNT >= 0x0500 */

            //#if(WINVER >= 0x0500)
            public const uint WS_EX_NOINHERITLAYOUT = 0x00100000; // Disable inheritence of mirroring by children
            public const uint WS_EX_LAYOUTRTL = 0x00400000; // Right to left mirroring
                                                            //#endif /* WINVER >= 0x0500 */

            //#if(_WIN32_WINNT >= 0x0500)
            public const uint WS_EX_COMPOSITED = 0x02000000;
            public const uint WS_EX_NOACTIVATE = 0x08000000;
            //#endif /* _WIN32_WINNT >= 0x0500 */
        }


        ChromeDriver cd = new ChromeDriver(@"chromedriver_win32");

        public FromChromeTest()
        {
            InitializeComponent();

            this.Width = 700;
            this.ConsoleWidth = this.Width;
            folderViewPtr = FindWindow("Progman", null);
            folderViewPtr = FindWindowEx(folderViewPtr, IntPtr.Zero, "SHELLDLL_DefView", null);
            folderViewPtr = FindWindowEx(folderViewPtr, IntPtr.Zero, "SysListView32", "FolderView");

            //SetWindowLong(this.Handle, -8, (int)folderViewPtr); //GWL_HWNDPARENT

            Process p = Process.Start("chromedriver.exe", "");
            Thread.Sleep(500); // Allow the process to open it's window
            cmdPtr = p.MainWindowHandle;

            SetParent(cmdPtr, this.Handle);

            string uri = "https://online.agah.com/";
            //Run selenium
            cd.Url = uri + "Auth/login";
            cd.Navigate();
            

            SetWindowLong(this.Handle, -20, (int)(GetWindowLong(this.Handle, -20) | WS.WS_CLIPCHILDREN));

            // Remove border and whatnot
            SetWindowLong(cmdPtr, GWL_STYLE, (int)(WS.WS_VISIBLE));

            long exStyle = GetWindowLong(p.MainWindowHandle, GWL_EXSTYLE);
            exStyle &= ~(WS.WS_EX_APPWINDOW | WS.WS_EX_CLIENTEDGE);


            SetWindowLong(p.MainWindowHandle, GWL_EXSTYLE, (int)0);

            MoveWindow(cmdPtr, -2, -2, this.ConsoleWidth, this.Height, true);

            SetWindowPos(this.Handle, (IntPtr)1, this.Left, this.Top, this.Width, this.Height, 0);

            timer1.Start();
        }


        protected override void WndProc(ref Message message)
        {
            const int WM_SYSCOMMAND = 0x0112;
            const int SC_MOVE = 0xF010;
            const int WM_WINDOWPOSCHANGING = 0x0046;

            switch (message.Msg)
            {
                case WM_SYSCOMMAND:
                    int command = message.WParam.ToInt32() & 0xfff0;
                    if (command == SC_MOVE)
                    {
                        //return;
                    }
                    break;

                case WM_WINDOWPOSCHANGING:
                    SetWindowPos(this.Handle, (IntPtr)1, this.Left, this.Top, this.Width, this.Height, 0x0004);
                    Debug.Print("WM_WINDOWPOSCHANGING");
                    break;
            }

            base.WndProc(ref message);
        }

        protected override void OnResize(EventArgs e)
        {
            if (this.cmdPtr != IntPtr.Zero)
            {
                MoveWindow(cmdPtr, 0, 0, this.ConsoleWidth, this.Height, true);
            }
            base.OnResize(e);
        }


        protected override void OnHandleDestroyed(EventArgs e)
        {
            if (cmdPtr != IntPtr.Zero)
            {
                PostMessage(cmdPtr, 0x0010, 0, 0);
            }
            base.OnHandleDestroyed(e);
        }

        [DllImport("user32.dll")]
        static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);

        [DllImport("user32.dll", SetLastError = true)]
        static extern UInt32 GetWindowLong(IntPtr hWnd, int nIndex);

        [DllImport("user32.dll")]
        static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

        [DllImport("User32.dll")]
        static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool repaint);

        [DllImport("User32.dll")]
        static extern bool PostMessage(IntPtr hWnd, uint message, int wparam, int lparam);

        [DllImport("User32.dll")]
        static extern void SetActiveWindow(IntPtr hWnd);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool IsWindow(IntPtr hWnd);

        [DllImport("user32.dll")]
        static extern void SetWindowPos(IntPtr hWnd, IntPtr hWndNew, int x, int y, int cx, int cy, UInt32 uFlags);

        [DllImport("user32.dll")]
        static extern IntPtr GetActiveWindow();

        [DllImport("user32.dll")]
        static extern IntPtr GetDesktopWindow();

        [DllImport("user32.dll")]
        static extern IntPtr WindowFromPoint(int xPoint, int yPoint);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

        [DllImport("user32.dll")]
        static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

        [DllImport("user32.dll")]
        static extern IntPtr FindWindowEx(IntPtr hWnd, IntPtr hWndA, string lpClassName, string lpWindowName);

        private void FromChromeTest_Load(object sender, EventArgs e)
        {
            this.Left = System.Windows.Forms.Screen.PrimaryScreen.WorkingArea.Right / 2 - this.Width / 2;
            this.Top = 0;
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            //check if cmd still exists
            if (!IsWindow(cmdPtr))
            {
                Application.Exit();
            }
        }

    }

}