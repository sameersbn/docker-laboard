angular.module('laboard-frontend')
    .constant(
        'LABOARD_CONFIG',
        {
            gitlabUrl: '{{GITLAB_URL}}',
            socketIoPort: 80,
            defaultColumns: [
                {
                    title: 'Sandbox',
                    position: 0
                },
                {
                    title: 'Backlog',
                    position: 1
                },
                {
                    title: 'Accepted',
                    position: 2
                },
                {
                    title: 'Review',
                    position: 3,
                    theme: 'info'
                },
                {
                    title: 'Done',
                    position: 4,
                    theme: 'success',
                    closable: true
                }
            ]
        }
    );
