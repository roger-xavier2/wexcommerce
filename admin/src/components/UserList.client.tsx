'use client'

import React, { useMemo, useState } from 'react'
import { useRouter } from 'next/navigation'
import {
  Tooltip,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
} from '@mui/material'
import { Inventory as OrdersIcon, Delete as DeleteIcon } from '@mui/icons-material'
import { format } from 'date-fns'
import { fr, enUS } from 'date-fns/locale'
import * as wexcommerceHelper from ':wexcommerce-helper'
import { LanguageContextType, useLanguageContext } from '@/context/LanguageContext'
import { strings as commonStrings } from '@/lang/common'
import { strings } from '@/lang/user-list'
import env from '@/config/env.config'
import * as UserService from '@/lib/UserService'
import { UserContextType, useUserContext } from '@/context/UserContext'
import * as helper from '@/utils/helper'
import PagerComponent from './Pager'
import EmptyListComponent from './EmptyList'

import styles from '@/styles/user-list.module.css'

export const EmptyList: React.FC = () => (
  <EmptyListComponent text={strings.EMPTY_LIST} marginTop />
)

interface PagerProps {
  page: number
  totalRecords: number
  rowCount: number
  keyword: string
}

export const Pager: React.FC<PagerProps> = ({
  page,
  totalRecords,
  rowCount,
  keyword,
}) => {
  const router = useRouter()

  return (
    <PagerComponent
      page={page}
      pageSize={env.PAGE_SIZE}
      rowCount={rowCount}
      totalRecords={totalRecords}
      alwaysVisible
      className={styles.pager}
      onPrevious={() => router.push(`/users?${`p=${page - 1}`}${(keyword !== '' && `&k=${encodeURIComponent(keyword)}`) || ''}`)}
      onNext={() => router.push(`/users?${`p=${page + 1}`}${(keyword !== '' && `&k=${encodeURIComponent(keyword)}`) || ''}`)}
    />
  )
}

interface OrdersAction {
  userId: string
  isAdmin?: boolean
}

export const Actions: React.FC<OrdersAction> = ({ userId, isAdmin }) => {
  const router = useRouter()
  const { user } = useUserContext() as UserContextType
  const [openDelete, setOpenDelete] = useState(false)
  const deletingDisabledReason = useMemo(() => {
    if (isAdmin) return strings.DELETE_DISABLED_ADMIN
    if (user?._id && user._id === userId) return strings.DELETE_DISABLED_ADMIN
    return ''
  }, [isAdmin, user?._id, userId])

  return (
    <>
      <Tooltip title={strings.ORDERS}>
        <IconButton onClick={() => {
          router.push(`/orders?u=${userId}`)
        }}
        >
          <OrdersIcon />
        </IconButton>
      </Tooltip>

      <Tooltip title={commonStrings.DELETE}>
        <span>
          <IconButton
            color="error"
            disabled={!!deletingDisabledReason}
            onClick={() => setOpenDelete(true)}
          >
            <DeleteIcon />
          </IconButton>
        </span>
      </Tooltip>

      <Dialog
        open={openDelete}
        onClose={() => setOpenDelete(false)}
        maxWidth="xs"
        fullWidth
      >
        <DialogTitle>{commonStrings.CONFIRM_TITLE}</DialogTitle>
        <DialogContent>{strings.DELETE_USER}</DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDelete(false)}>
            {commonStrings.CANCEL}
          </Button>
          <Button
            color="error"
            variant="contained"
            onClick={async () => {
              try {
                const status = await UserService.deleteUsers([userId])
                if (status === 200) {
                  helper.info(strings.USER_DELETED)
                  setOpenDelete(false)
                  router.refresh()
                } else {
                  helper.error(undefined)
                }
              } catch (err) {
                helper.error(err)
              }
            }}
          >
            {commonStrings.DELETE}
          </Button>
        </DialogActions>
      </Dialog>
    </>
  )
}

export const FullName: React.FC = () => (
  <span className={styles.userLabel}>{commonStrings.FULL_NAME}</span>
)

export const Email: React.FC = () => (
  <span className={styles.userLabel}>{commonStrings.EMAIL}</span>
)

export const Phone: React.FC = () => (
  <span className={styles.userLabel}>{commonStrings.PHONE}</span>
)

export const Address: React.FC = () => (
  <span className={styles.userLabel}>{commonStrings.ADDRESS}</span>
)

interface SubscribedAtProps {
  value: Date
}

export const SubscribedAt: React.FC<SubscribedAtProps> = ({ value }) => {
  const { language } = useLanguageContext() as LanguageContextType
  const _fr = language === 'fr'
  const _format = wexcommerceHelper.getDateFormat(language)
  const _locale = _fr ? fr : enUS
  return (
    <>
      <span className={styles.userLabel}>{strings.SUBSCRIBED_AT}</span>
      <span>{wexcommerceHelper.capitalize(format(new Date(value), _format, { locale: _locale }))}</span>
    </>)
}
