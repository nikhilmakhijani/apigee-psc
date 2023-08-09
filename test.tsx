import React, { useState } from 'react';
import {
  Button,
  Divider,
  Icon,
  VStack,
  Text,
  useColorModeValue,
} from '@chakra-ui/react';
import { RiAddfill } from 'react-icons/ri';
import {
  isToday,
  isYesterday,
  isWithinInterval,
  sub,
} from 'date-fns';
import { Session } from '../../common/Api'; // Import your Session type

interface SessionsSidebarProps {
  sessions: Session[];
  currentSession: Session | null;
  setCurrentSession: React.Dispatch<React.SetStateAction<Session | null>>;
  openCreateSession: () => void;
}

const SessionButton = ({
  session,
  isCurrentSession,
  onClick,
  onEdit,
  onDelete,
}: SessionButtonProps) => {
  const tip = `started ${formatDistanceToNow(session.created, {
    includeSeconds: true,
  })} ago`;

  return (
    <Tooltip label={tip}>
      <ButtonGroup isAttached variant={isCurrentSession ? 'solid' : 'ghost'} w="100%">
        <Button variant={isCurrentSession ? 'solid' : 'ghost'} onClick={onClick} w="100%">
          {session.name}
        </Button>
        <Button onClick={onDelete} colorScheme="red" leftIcon={<RiDeleteBin6Line />}>
          Delete
        </Button>
      </ButtonGroup>
    </Tooltip>
  );
};

const SessionsSidebar = (props: SessionsSidebarProps) => {
  const headerCol = useColorModeValue('gray.600', 'gray.400');
  const { currentSession, setCurrentSession, openCreateSession } = props;

  const [sessions, setSessions] = useState(props.sessions);

  const handleSessionEdit = (sessionId: string, editedName: string) => {
    const updatedSessions = sessions.map((session) =>
      session.id === sessionId ? { ...session, name: editedName } : session
    );
    setSessions(updatedSessions);
  };

  const handleSessionDelete = (sessionId: string) => {
    const updatedSessions = sessions.filter((session) => session.id !== sessionId);
    setSessions(updatedSessions);
    if (currentSession?.id === sessionId) {
      setCurrentSession(null);
    }
  };

  // Define your session intervals and sessionMap here...

  return (
    <VStack align="left">
      <Button
        colorScheme="gray"
        variant="ghost"
        onClick={openCreateSession}
        w="97%"
        my={3}
        leftIcon={<Icon as={RiAddfill} />}
      >
        New Session
      </Button>
      <Divider />

      {Object.keys(sessionMap).map((title, mapIndex) => {
        if (sessionMap[title].length === 0) {
          return null;
        }
        return (
          <React.Fragment key={mapIndex}>
            <Text fontWeight="semibold" color={headerCol} mt={2}>
              {title}
            </Text>
            {sessionMap[title].map((session, titleIndex) => (
              <SessionButton
                key={titleIndex}
                session={session}
                isCurrentSession={currentSession === session}
                onClick={() => setCurrentSession(session)}
                onEdit={(editedName) => handleSessionEdit(session.id, editedName)}
                onDelete={() => handleSessionDelete(session.id)}
              />
            ))}
          </React.Fragment>
        );
      })}
    </VStack>
  );
};

export default SessionsSidebar;
