package VPoker::Debugger;

use strict;
use warnings;
use diagnostics;

use Time::localtime;

use Exporter;
our @EXPORT = qw( debug_message log_file);    #  Exporting some functions
our @ISA    = qw( Exporter );

our $the_DebugFile;

use constant TRUE  => 1;
use constant FALSE => 0;

my $first_Action = TRUE;

#  debug_message
#
sub debug_message {
    die('use log_file to set debug file first') unless $the_DebugFile;

    if ( $first_Action == TRUE ) {

        #  Open for writing,
        #    i.e. delete the old file.
        open( DEBUG, ">", $the_DebugFile );
        $first_Action = FALSE;
    }
    else {

        #  Open for appending.
        open( DEBUG, ">>", $the_DebugFile );
    }

    #  Print time to debug log.
    print( DEBUG scalar( gmtime() ) );
    foreach my $Msg (@_) {
        print( DEBUG " " );
        print( DEBUG $Msg );
    }
    print( DEBUG "\n" );

    #  Immediately close file,
    #    to create a persistent debug log.
    close(DEBUG);
}

sub log_file {
    $the_DebugFile = shift;
}

return 1;
