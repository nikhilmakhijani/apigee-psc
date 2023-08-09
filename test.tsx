
  return (
    <Tooltip label={tip}>
      <ButtonGroup isAttached variant={isCurrentSession ? 'solid' : 'ghost'} w="100%">
        <IconButton aria-label="Edit" icon={<RiPencilLine />} onClick={handleEditClick} />
        {isEditing ? (
          <>
            <Input value={editedName} onChange={(e) => setEditedName(e.target.value)} />
            <IconButton aria-label="Save" icon={<FaCheck />} onClick={handleSaveClick} />
            <IconButton aria-label="Cancel" icon={<FaTimes />} onClick={handleCancelClick} />
          </>
        ) : (
          <Button variant={isCurrentSession ? 'solid' : 'ghost'} w="100%" onClick={onClick}>
            {session.name}
          </Button>
        )}
        <IconButton aria-label="Delete" icon={<RiDeleteBin6Line />} onClick={onDelete} />
      </ButtonGroup>
    </Tooltip>
  );
};
